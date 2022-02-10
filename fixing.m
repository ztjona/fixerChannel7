%This script modifies the data from user that has the channel 7 with an
%offset. Assumes data is converted to range -1 1
%
%INSTRUCTIONS
% 1. Delete the example users in folder ```data```.
% 2. Paste the users to fix in the folder ```data```, and run this script
% with:
% >> fixing
% 2.1 Copy and paste the photo of each user to the correspoding newData
% folder.
% 3. Export the formated users from newData.

%{
Laboratorio de Inteligencia y Visión Artificial
ESCUELA POLITÉCNICA NACIONAL
Quito - Ecuador

autor: ztjona
jonathan.a.zea@ieee.org

"I find that I don't understand things unless I try to program them."
-Donald E. Knuth

28 January 2022
Matlab R2021b.
%}

clear all
close all
clc

warning off backtrace
%% Configuración
threshold = 0.7;
noteSave = 'Emg signals of channel 7 had an offset, and was centered';



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% FROM HERE NOT MODIFY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% libs and definitions
addpath(genpath('srcs'))
gestures = {'relax', 'sync', 'waveIn', 'waveOut', 'fist', 'open',...
    'pinch', 'up', 'down', 'forward', 'backward', 'left', 'right'};
folder = '.\data\';
outputFolder = '.\newData\';

%% execution
clc

files = dir(folder);
%--- loop users
for f = files'
    if isequal(f.name, '.') || isequal(f.name, '..') || ~f.isdir
        continue
    end

    user = f.name;
    fprintf('Modifing %s\n', user);

    vars = load([folder user '\userData.mat'], 'userData');
    userData = vars.userData;
    clear vars;

    %--- loop gestures
    allModified = true; % default
    data = struct(); % by gesture
    for g = gestures
        fprintf('\t\tGesture %s\n', g{1});
        % --- fixing
        [userData.gestures.(g{1}).data, ~, modifiedU] = fixReps( ...
            userData.gestures.(g{1}).data, threshold);
        
        if ~isequal(g{1}, 'sync')
            vars = load([folder user '\' g{1} '.mat'], 'reps');
            reps = vars.reps;
            clear vars;

            [reps.(g{1}).data, avgs, modifiedG] = fixReps(reps.(g{1}).data, ...
                threshold);

        else
            modifiedG = true; % easy solution
        end

        allModified = allModified && modifiedG && modifiedU;
        data.(g{1}) = reps;
    end


    % --- saving in the case to save
    if allModified
        fprintf('\tsaving files\n');
        userData.notes = noteSave;
        outputFolderUser = [outputFolder user '\'];
        [~, ~, ~] = mkdir(outputFolderUser);

        save([outputFolderUser 'userData.mat'], "userData");

        for g = gestures
            reps = data.(g{1});
            save([outputFolderUser  '\' g{1} '.mat'], 'reps');
        end

        fprintf('%s done!\n\n', user)
    else
        warning('%s not modified!!!', user);
    end
end
