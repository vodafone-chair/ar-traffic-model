function TrafficModel = DefaultTrafficModel()
% This Function contains (and explains) the default parameters (as obtained from the video
% data) of the Traffic Model.
%
% One Convenient way could be to load this model and modify it where
% necessary.


TrafficModel = struct();

%% General:
% TrafficModel.General.fps = 60;
% Distribution for frame inter arrival times (fixed to 1 / 60fps ):
TrafficModel.InterArrivalTimeDist = DiscreteDist(1, 1/60);

%% P Frames:
% This model is used (in the log domain!) for the P-Frames in the independent mode:
TrafficModel.PFrameModel.LogFrameSizeDist = makedist('Normal', 'mu', 9.5286, 'sigma', 0.784133);

% This model is used (in the log domain!) for the first P-Frame of a busy period (only for ARIMA)
TrafficModel.PFrameModel.LogInitFrameSizeDist = makedist('Normal', 'mu', 7.93411, 'sigma', 1.5759);
% ... but with a certain probability the size of the last P-Frame of the previous period will be used
%     (set to 0 to turn off)
TrafficModel.PFrameModel.ContinueProbability = 0.8;
% TrafficModel.PFrameModel.ContinueProbability = 0.0;

% TrafficModel.PFrameModel.Type = 'independent';
TrafficModel.PFrameModel.Type = 'ARIMA';

% ARIMA Parameters:
TrafficModel.PFrameModel.D        = 1;
% TrafficModel.PFrameModel.AR       = [-0.104166	0.574846	0.209096	0.0901297	0.0442575	];
% TrafficModel.PFrameModel.MA       = [-0.372604	-0.665013	0.0837112	];
% TrafficModel.PFrameModel.Constant =  1.15354e-05	;
% TrafficModel.PFrameModel.Var      =  0.0633286	;
TrafficModel.PFrameModel.AR       = [-0.642442	-0.340076	-0.161739	-0.116258	-0.0742357	-0.0627455	-0.0362322	-0.0593347	];
TrafficModel.PFrameModel.MA       = [0.172323	];
TrafficModel.PFrameModel.Constant =  8.81407e-05	;
TrafficModel.PFrameModel.Var      =  0.0635221	;
TrafficModel.PFrameModel.EpsilonDistribution = makedist('Normal', 'mu', 0, 'sigma', sqrt(TrafficModel.PFrameModel.Var ));

% Bounds of the ARIMA process (in the log domain):
TrafficModel.PFrameModel.bounds  = log( [500 1e5] );

% Distribution of P-Frames when the process is idle:
TrafficModel.PFrameModel.IdleLogDistribution = DiscreteDist(1, log(70));

%% Key Frames:
% Interval of Key Frames (counted in frames)
TrafficModel.KeyFrameModel.IntervalDistribution   = DiscreteDist(1, 250); % fixed to 250
% Bound the Key Frames:
TrafficModel.KeyFrameModel.Bounds                 = [0 exp(12.58)];
% Correlate (in the log domain) the busy Key-Frames with the P-Frames (works best with both being log-normally distributed)
TrafficModel.KeyFrameModel.BusyPFrameCorrelation        = 0.63;

% Distribution of the busy Key Frames:
busy_mu    = 12.0508;
busy_sigma = 0.162503;
TrafficModel.KeyFrameModel.BusyLogDistribution = makedist('Normal', 'mu', busy_mu, 'sigma', busy_sigma);

% Distribution of the idle Key Frames:
TrafficModel.KeyFrameModel.IdleLogDistribution = makedist('Normal', 'mu', 11.84, 'sigma', 0.05);
% TrafficModel.KeyFrameModel.IdleLogDistribution = DiscreteDist(1, round(11.84));

% obsolete
% TrafficModel.KeyFrameModel.BusyDistribution    = makedist('LogNormal', 'mu', busy_mu, 'sigma',busy_sigma);
% TrafficModel.KeyFrameModel.IdleDistribution    = makedist('LogNormal', 'mu', 11.84, 'sigma', 0.05);


%% Busy / Idle:
% Distributions of the busy and idle period lengths (counted in frames, will be rounded later):
TrafficModel.StateModel.BusyFramesModel = makedist('Exponential', 'mu', 412.536);
TrafficModel.StateModel.IdleFramesModel = makedist('Exponential', 'mu', 139.189);
