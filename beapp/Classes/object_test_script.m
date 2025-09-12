% Script to test uifigure function and hierarchial parameter sets in
% uitrees



%% Using uifigure with uigridlayout

f = uifigure;
gl = uigridlayout(f, [2, 3]);  % 2x3 grid
ax1 = uiaxes(gl);
ax1.Layout.Row = 1;
ax1.Layout.Column = 1;
plot(ax1, rand(1,10));
xlabel(ax1,'x')
ylabel(ax1,'rand(x)')
title(ax1,'Rand')

ax2 = uiaxes(gl);
ax2.Layout.Row = 1;
ax2.Layout.Column = 2;
plot(ax1, rand(1,10));

btn = uibutton(gl, 'Text', 'Click Me');
btn.Layout.Row = 2;
btn.Layout.Column = [1 2];  % Span 2 columns

btn2 = uibutton(gl, 'Text', 'Click Me');
btn2.Layout.Row = [1 2]; % Span both rows
btn2.Layout.Column = 3;


%% 


happeNode = paramNode("HAPPE","ICA","ValueSet",["ICA","Wavelet"]);
beappNode = paramNode("BEAPP","ICA","ValueSet",["ICA","Wavelet"]);
testNode = paramNode("Foo","ChoiceA","ValueSet",["ChoiceA","ChoiceB","ChoiceC"]);

parent = paramNode("Analysis", "HAPPE","ValueSet",["HAPPE", "DEAPP"],"Children",[happeNode, beappNode, testNode]);

treeObj = parameterTree([parent])

guiObj = ParameterTreeGUI(treeObj)