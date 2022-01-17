function TrafficModel = checkTrafficModel(TrafficModel)
% corrects the TrafficModel, if necessary


% Initial Frame Size and Bounds:
if TrafficModel.PFrameModel.bounds(1) > -inf || TrafficModel.PFrameModel.bounds(2) < inf
    % avoids that the initial value can exceed the bounds
    TrafficModel.PFrameModel.LogInitFrameSizeDist = truncate(...
        TrafficModel.PFrameModel.LogInitFrameSizeDist, ...
        TrafficModel.PFrameModel.bounds(1), ...
        TrafficModel.PFrameModel.bounds(2));
end
