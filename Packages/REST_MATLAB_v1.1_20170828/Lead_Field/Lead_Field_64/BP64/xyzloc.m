clear all
close all
clc
[Name_loc, pathname_loc] = uigetfile({'*.txt',...
    'Loc Files (*.txt)';'*.*', 'All Files (*.*)';}, ...
    'Select loc file');
[y, x, z, loc] = textread(Name_loc,'%*d %f %f%f %s',-1);
y = -y;
ele_pos = [x, y, z];
delchann = [20];
ele_pos(delchann, :) = [];
save BPloc63.txt ele_pos -ascii;
