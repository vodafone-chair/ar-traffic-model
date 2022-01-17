function [times, framesizes, states, key_indices] = traffic_simulation(N, TrafficModel, do_plot)
% Simulates Video Traffic
%
% INPUT:
%   N .............. Number of frames
%   TrafficModel ... Struct that contains all Traffic Parameters 
%                    (see DefaultTrafficModel.m for details)
%   do_plot ........ boolean, plots the results if true
% 
% OUTPUT:
%   times .......... (Nx1) time instances (seconds)
%   framesizes ..... (Nx1) frame sizes at each time instance (in byte)
%   states ......... (Nx1) states at each time instance busy (true) idle (false)
%   key_indices .... vector containing the indices of the key frames


%% default parameters
if nargin < 2 || isempty(TrafficModel)
    TrafficModel = DefaultTrafficModel();
end
if nargin < 3
    do_plot = false;
end

TrafficModel = checkTrafficModel(TrafficModel);

%% setup
% times = (0 : N-1)' / TrafficModel.General.fps;
times      = cumsum([0; TrafficModel.InterArrivalTimeDist.random(N-1,1)]);
states     = false(N,1);
framesizes = nan(N,1);

%% generate idle / busy periods
% pbusystart = TrafficModel.StateModel.BusyFramesMean / (TrafficModel.StateModel.BusyFramesMean + TrafficModel.StateModel.IdleFramesMean);
pbusystart = TrafficModel.StateModel.BusyFramesModel.mean / (TrafficModel.StateModel.BusyFramesModel.mean + TrafficModel.StateModel.IdleFramesModel.mean);
busyperiod0 = rand() < pbusystart;

busyperiod = busyperiod0;
tn = 1;
period_ends = [];
period_lengths = [];
while tn < N
    
    if busyperiod
        frames = round( TrafficModel.StateModel.BusyFramesModel.random() );
    else
        frames = round( TrafficModel.StateModel.IdleFramesModel.random() );
    end    
    % no "empty phases":
    frames = max(1, frames);
    % limit it to N
    if tn + frames - 1 > N
        frames = N-tn+1;
    end
    
    states( tn : min(tn+frames-1, N) ) = busyperiod;
    
    tn = tn + frames;    
    period_lengths(end+1) = frames;
    period_ends(end+1)    = tn-1;
    busyperiod = ~busyperiod;    
end

period_states = false(size(period_ends));
period_states(end-1:-2:1) =  busyperiod;
period_states(end  :-2:1) = ~busyperiod;

nperiods = length(period_ends);

%% P-Frames:

f0 = 1;
for pi = 1:nperiods
    len  = period_lengths(pi);    
    f1   = f0 + len -1;
%     fprintf('Generate frames %d ... %d (length %d)\n', f0, f1, len);
    
    if period_states(pi)
        % busy
        switch TrafficModel.PFrameModel.Type
            case 'ARIMA'
                if pi < 3 || rand() >  TrafficModel.PFrameModel.ContinueProbability                    
                    y0 = TrafficModel.PFrameModel.LogInitFrameSizeDist.random();
                else % continue with the old value:
                    y0 = ye;
                end
                framesizes(f0:f1) = bounded_ARIMA(len, TrafficModel.PFrameModel, y0);
                ye = framesizes(f1);
            otherwise
                % independent frames:
                framesizes(f0:f1) = TrafficModel.PFrameModel.LogFrameSizeDist.random(len, 1);
        end
    else
        % idle
        framesizes(f0:f1) = TrafficModel.PFrameModel.IdleLogDistribution.random(len,1);
    end
    
    f0 = f1+1;
end

%% Key Frames:

% positions:
% key_indices = 1 : TrafficModel.KeyFrameModel.Interval : N;
key_indices = 1;
new_index = key_indices(end) + TrafficModel.KeyFrameModel.IntervalDistribution.random();
while new_index <= N
   key_indices(end+1) = new_index;
   new_index = key_indices(end) + TrafficModel.KeyFrameModel.IntervalDistribution.random();
end


% n_key_frames = length(key_indices);
busy_key_indices = key_indices( states(key_indices) );
idle_key_indices = key_indices( ~states(key_indices) );
n_busy_key_frames = length(busy_key_indices);
n_idle_key_frames = length(idle_key_indices);

% Idle Key Frames
idle_key_frames = TrafficModel.KeyFrameModel.IdleLogDistribution.random( n_idle_key_frames, 1 );
idle_key_frames = exp(idle_key_frames);

% Busy Key Frames (correlate with P-Frames if desired)
rho = TrafficModel.KeyFrameModel.BusyPFrameCorrelation;
if rho == 0
    % No Correlation:
%     busy_key_frames = TrafficModel.KeyFrameModel.BusyDistribution.random( n_busy_key_frames, 1 );    
    busy_key_frames = TrafficModel.KeyFrameModel.BusyLogDistribution.random( n_busy_key_frames, 1 );    
    busy_key_frames = exp( busy_key_frames );
else
    % Correlation coefficient rho
    muz    = TrafficModel.KeyFrameModel.BusyLogDistribution.mean;
    mux    = TrafficModel.PFrameModel.LogFrameSizeDist.mean;
    sigmaz = sqrt( TrafficModel.KeyFrameModel.BusyLogDistribution.var );
    sigmax = sqrt( TrafficModel.PFrameModel.LogFrameSizeDist.var );
    alpha  = rho * sigmaz / sigmax;
    % aux var:
    muy = muz - alpha * mux;
    sigmay = sqrt( sigmaz^2 - alpha^2 * sigmax^2 );
    %
    Ydist = makedist('Normal', 'mu', muy, 'sigma', sigmay);
    Y     = Ydist.random(  n_busy_key_frames, 1 );
    X     = framesizes(busy_key_indices);
    busy_log_key_frames = alpha * X + Y;
    busy_key_frames = exp(busy_log_key_frames);
end

% bounds:
busy_key_frames = max(busy_key_frames, TrafficModel.KeyFrameModel.Bounds(1));
busy_key_frames = min(busy_key_frames, TrafficModel.KeyFrameModel.Bounds(2));

idle_key_frames = max(idle_key_frames, TrafficModel.KeyFrameModel.Bounds(1));
idle_key_frames = min(idle_key_frames, TrafficModel.KeyFrameModel.Bounds(2));

%%
% transform to linear domain:
framesizes = exp(framesizes);

%% Add Key Frames to the P-Frames:

% corr(busy_key_frames, framesizes(busy_key_indices))
framesizes(busy_key_indices) = framesizes(busy_key_indices) + busy_key_frames;
framesizes(idle_key_indices) = framesizes(idle_key_indices) + idle_key_frames;

%% Plot nicely if desired:
if do_plot
    figure; 
    hold on;
    yscaling = 8 / 1e6 * 60; % MBits @60fps
    m = mean(framesizes);
    m2 = mean(framesizes(states));
    h = bar(times, framesizes*yscaling);
    bw = get(h, 'BarWidth');
    set(h, 'BarWidth', 10*bw);
    tmp_framesizes = framesizes*0;
    tmp_framesizes(key_indices) = framesizes(key_indices);
    h = bar(times, tmp_framesizes*yscaling);
    bw = get(h, 'BarWidth');
    set(h, 'BarWidth', 10*bw);
    plot(times, states * m * yscaling);
    plot(times([1, end]), [1 1] * m * yscaling, 'k-.');
    plot(times([1, end]), [1 1] * m2 * yscaling, 'r-.');
    title('Traffic');
    ylabel('Instantaneous Data Rate [Mbit/s]');
    xlabel('Time [s]');
    legend('Frames', 'KeyFrames', 'States', sprintf('avg bitrate (%d kpbs)', round(m * yscaling * 1e3)),...
                                            sprintf('avg busy bitrate (%d kpbs)', round(m2 * yscaling * 1e3)))
end

