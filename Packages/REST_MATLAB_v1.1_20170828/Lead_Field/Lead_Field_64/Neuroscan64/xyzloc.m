clear all
close all
clc
[Name_loc, pathname_loc] = uigetfile({'*.txt',...
    'Loc Files (*.txt)';'*.*', 'All Files (*.*)';}, ...
    'Select loc file');
[y, x, z, loc] = textread(Name_loc,'%*d %f %f%f %s',-1);
y = -y;
ele_pos = [x, y, z];
delchann = [14 20 63 64 65 66];
ele_pos(delchann, :) = [];
save Neuroscan62.txt ele_pos -ascii;
