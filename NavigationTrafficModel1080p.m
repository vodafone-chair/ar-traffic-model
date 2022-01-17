function TrafficModel = NavigationTrafficModel1080p()
% This Function contains (and explains) the parameters (as obtained from the video
% data) of the Traffic Model for the navigation use case in 1080p
% resolution. (with keyframes only at the start)
%



TrafficModel = struct();

%% General:
% TrafficModel.General.fps = 60;
% Distribution for frame inter arrival times (fixed to 1 / 60fps ):
TrafficModel.InterArrivalTimeDist = DiscreteDist(1, 1/60);


%% BEGIN GENERATED CODE FOR TRAFFIC MODEL CONFIGURATION 
%% P Frames:
% This model is used (in the log domain!) for the P-Frames in the independent mode:
TrafficModel.PFrameModel.LogFrameSizeDist = makedist('Normal', 'mu', 8.12579, 'sigma', 0.454317);
% This model is used (in the log domain!) for the first P-Frame of a busy period (only for ARIMA)
TrafficModel.PFrameModel.LogInitFrameSizeDist = makedist('Normal', 'mu', 7.03877, 'sigma', 0.880261);
% ... but with a certain probability the size of the last P-Frame of the previous period will be used
%     (set to 0 to turn off)
TrafficModel.PFrameModel.ContinueProbability = 0.4;
% TrafficModel.PFrameModel.Type = 'independent';
TrafficModel.PFrameModel.Type = 'ARIMA';
% ARIMA Parameters:
% Overall Model Coefficients
TrafficModel.PFrameModel.D       = [1];
TrafficModel.PFrameModel.AR       = [0.865553	0.0212779	0.0721626	];
TrafficModel.PFrameModel.MA       = [-1.31911	0.326399	];
TrafficModel.PFrameModel.Constant =  2.40275e-05	;
TrafficModel.PFrameModel.Var      =  0.0324771	;
TrafficModel.PFrameModel.EpsilonDistribution = makedist('Normal', 'mu', 0, 'sigma', TrafficModel.PFrameModel.Var);
% Bounds of the ARIMA process (in the log domain):
TrafficModel.PFrameModel.bounds  = [5.02388 9.32367];
% Distribution of P-Frames when the process is idle:
TrafficModel.PFrameModel.IdleLogDistribution = makedist('Normal', 'mu', 4.8993, 'sigma', 0.107087);
%% Key Frames:
% Interval of Key Frames (counted in frames):
% TrafficModel.KeyFrameModel.IntervalDistribution   = DiscreteDist(1, 250); % fixed to 250 
% set Key frame intervals to infinity (first frame will still be a key frame)
TrafficModel.KeyFrameModel.IntervalDistribution = DiscreteDist(1, inf);
% Bound the Key Frames:
TrafficModel.KeyFrameModel.Bounds                 = [0 exp(9.10209)];
% Correlate (in the log domain) the busy Key-Frames with the P-Frames (works best with both being log-normally distributed)
TrafficModel.KeyFrameModel.BusyPFrameCorrelation  = 0.662501;
% Distribution of the busy Key Frames:
TrafficModel.KeyFrameModel.BusyLogDistribution = makedist('Normal', 'mu', 8.7598, 'sigma', 0.207139);
% Distribution of the idle Key Frames:
TrafficModel.KeyFrameModel.IdleLogDistribution = DiscreteDist([1], [8.47408]);
%% Busy / Idle:
% Distributions of the busy and idle period lengths (counted in frames, will be rounded later:
TrafficModel.StateModel.BusyFramesModel = makedist('Exponential', 'mu', 335.515);
TrafficModel.StateModel.IdleFramesModel = makedist('Exponential', 'mu', 141.01);
%% END GENERATED CODE FOR TRAFFIC MODEL CONFIGURATION 