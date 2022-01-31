function [data, avgs, modified] = fixReps(data, threshold)
% fixReps(data) moves the emg signal of channel 7 when the avg value of all
% repetitions is bigger than threshold.
%
% Inputs
%   data    m-by-1 cell, with every value as a struct with repetition
%           fields
%
% Outputs
%   data    m-by-1 cell, with every value as a struct with repetition
%           fields with modified channel 7
%   avgs    m-by-1 double, with the averages of the channel 7
%   modified bool, true when data was modified

%{
Laboratorio de Inteligencia y Visión Artificial
ESCUELA POLITÉCNICA NACIONAL
Quito - Ecuador

autor: ztjona
jonathan.a.zea@ieee.org
Cuando escribí este código, solo dios y yo sabíamos como funcionaba.
Ahora solo lo sabe dios.

"I find that I don't understand things unless I try to program them."
-Donald E. Knuth

30 January 2022
Matlab R2021b.
%}

%% Input Validation
arguments
    data (:, 1) cell
    threshold (1, 1) double
end

%--- in the case of ints
if any(abs(data{1}.emg) >= 2)
    avgs = [];
    modified = false;
    warning('Data outside of range, maybe format is not converted yet')
    return;
end

%% avgs
avgs = zeros(1, size(data, 1));

for i = 1:size(data, 1)
    channel7 = data{i}.emg(:, 7);
    avgs(i) = mean(channel7);
end

%--- weird limits
if any(avgs(i) < threshold)
    warning('Data not converted because mean channel value of %.2f below limit %.2f' ...
        , min(avgs(i)), threshold)
    modified = false;
    return;
end

theAvg = mean(avgs);

%% conversion
for i = 1:size(data, 1)
    data{i}.emg(:, 7) = data{i}.emg(:, 7) - theAvg;
end

modified = true;
