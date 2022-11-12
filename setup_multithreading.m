function [pool] = setup_multithreading(numberOfWorkers)
% This function setups the parallel pool only if no other pool is currently 
% running.
pool=gcp('nocreate');
if isempty(pool)
    pool=parpool(numberOfWorkers);
    fprintf('Created new Pool...');
end
fprintf('Number of workers: %d\n', pool.NumWorkers);
end

