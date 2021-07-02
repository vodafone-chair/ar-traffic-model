function y = bounded_ARIMA(N, model, y0)
% Implements a bounded ARIMA process
% 
% INPUT:
%   N ....... number of values to simulate
%   model ... struct containing all model parameters 
%             See an example in DefaultTrafficModel.m (PFrameModel)
%     .bounds ... 1x2 lower and upper bound (can be inf)
%     .AR ... coefficients of the auto-regressive part (alphas)
%     .MA ... coefficients of the moving-average part (betas)
%     .D .... Integration order (0 or 1)
%     .Constant ... Constant drift
%     .EpsilonDistribution ... Distribution of the Random Variable in each
%                              time step
%   y0 ...... Initial Value (Default 0)
%
% OUTPUT:
%   y ....... Nx1 vector containing the simulated values   


if nargin < 3    
    y0 = 0;
end

if ~isfield(model, 'bounds') || isempty(model.bounds)
    model.bounds = [-inf, inf];
end

lb = model.bounds(1);
ub = model.bounds(2);

assert(lb < ub);

% P = model.P;
% Q = model.Q;
D = model.D;

assert(D <= 1);

alphas = model.AR;
betas  = model.MA;
delta  = model.Constant;

if iscell(alphas)
    alphas = cell2mat(alphas);
end
if iscell(betas)
    betas = cell2mat(betas);
end

eps_dist = model.EpsilonDistribution;

y = nan(N, 1);
% epsilons = nan(N,1);
epsilons = eps_dist.random(N,1); % faster approach: pre-sample + apply bounds only when necessary.

lasty = y0;
for fi = 1:N
    if D==0
        yt = y(1:fi-1);
    else
        yt = diff(y(1:fi-1), D);
    end
    epst = epsilons(1:fi-1);
    
    Z = delta + delayedsum(alphas, yt) + delayedsum(betas, epst);
    
    eps_bounds = [lb, ub] - Z;
    if D==1
        eps_bounds = eps_bounds -lasty;
    end        
    
    if epsilons(fi) < eps_bounds(1) || epsilons(fi) > eps_bounds(2)
        % resample:        
        if diff(eps_dist.cdf(eps_bounds)) <= 0
            % truncation not possible (probability < 0)
            if epsilons(fi) > eps_bounds(2)
                % enforce negative epsilon
                eps_bounds = [-inf, 0];
            else
                % enforce positive epsilon
                eps_bounds = [0, inf];
            end
        end
        trunc_dist = truncate(eps_dist, eps_bounds(1), eps_bounds(2));
        epsilons(fi) = trunc_dist.random(1);
    end
    
    switch D
        case 0
            y(fi) = Z + epsilons(fi);
        case 1
            y(fi) = lasty + Z + epsilons(fi);
        otherwise
            warning('D > 1 not yet implemented');
    end
    
    %
    lasty = y(fi);
end

