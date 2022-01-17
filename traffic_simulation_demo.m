% Traffic Model Demo

rng(1); % reproducable results

N = 60 * 60; % 60 fps, 60 Seconds
do_plot = true;
% N = 1e5;
% do_plot = false;

TrafficModel = DefaultTrafficModel();

tic;
[times, framesizes] = traffic_simulation(N, TrafficModel, do_plot);
toc
box on; grid on;
title('Correlated Traffic Model');
% return


% Disable the Correlation Features in P and KeyFrames:
% TrafficModel = DefaultTrafficModel();
TrafficModel.PFrameModel.Type = 'independent';
TrafficModel.KeyFrameModel.BusyPFrameCorrelation = 0;

tic;
traffic_simulation(N, TrafficModel, do_plot);
toc
box on; grid on;
title('Uncorrelated Traffic Model');


%% no key frames:
rng(1);
% load default configuration:
TrafficModel = DefaultTrafficModel();
% set Key frame intervals to infinity (first frame will still be a key frame)
TrafficModel.KeyFrameModel.IntervalDistribution = DiscreteDist(1, inf);

tic;
[times, framesizes] = traffic_simulation(N, TrafficModel, do_plot);
toc
box on; grid on;
title('Correlated Traffic Model');