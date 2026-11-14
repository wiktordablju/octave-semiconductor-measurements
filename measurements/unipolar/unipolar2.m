clc
pkg load instrument-control
pkg load io
clear s;
s = serialport('COM3', 115200)
filename = "field_effect_transistor";
measurement_group = "measurement";
series_id = "series-1";
operator_labels = [{"Operator 1"}, {"Operator 2"}, {"Operator 3"}];
date = datestr(clock());
line_marker = [{"xb"}, {"xr"}, {"xg"}, {"xm"}, {"xk"}, {"xc"}];
line_color = [{"-b"}, {"-r"}, {"-g"}, {"-m"}, {"-k"}, {"-c"}];
line_col_mark = [{"-xb"}, {"-xr"}, {"-xg"}, {"-xm"}, {"-xk"}, {"-xc"}];
close all;
figure(1)
fig1 = gcf ();
hax1 = gca ();
fig1_title = "I_{D} = f(U_{DS}); U_{GS}=const";
y1_lab = "I_{D} [mA]";
y1_lo = -5;
y1_hi = 10;
x1_lab = "U_{DS} [V]";
x1_lo = -1;
x1_hi = 10;
figure1_title = [fig1_title "     @" measurement_group "/" series_id "/" date "@"];
title(hax1, figure1_title, "fontsize", 7);
axis(hax1, [x1_lo x1_hi y1_lo y1_hi]);
xlabel(hax1, x1_lab, "fontsize", 6);
ylabel(hax1, y1_lab, "fontsize", 6);
grid(hax1, "on");
hold on;
par_names = [{"U_{UDS1}=1V"}, {"U_{UDS2}=4V"}, {"U_{UDS3}=8V"}];
parameters = [ -1.25 -0.75 0 ];
numOfCurves = columns(parameters)
stimulus = [ -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6 0.8 1 1.2 1.4 1.7 2 3 4 6 8 10]
numOfPoints = columns(stimulus)
clear result1 data_table1 result2 data_table2
result1 = zeros(numOfPoints, numOfCurves);
result2 = zeros(numOfPoints, numOfCurves);
figure(1)
% Each parameter value produces one stimulus sweep.
for k = 1:numOfCurves
  fprintf(s, "VOLT1 %f\n", parameters(k));
  pause(0.2);
  for i = 1:numOfPoints
    fprintf(s, "VOLT2 %f\n", stimulus(i));
    % Allow the source to settle before reading.
    pause(1.5);
    flush(s);
    fprintf(s, 'MEAS:CURR? (@2)\n');
    pause(0.1);
    result1(i, k) = -sscanf(char(fread(s)), "%f")
    figure(1)
    h1 = plot(stimulus(i), result1(i, k), line_marker(k), "markersize", 4, "linewidth", 1);
  end
end
fprintf(s, "CURR 0.0001\n");
fprintf(s, "VOLT2 0\n");
flush(s);
clf(fig1);
figure(1)
fig1 = gcf ();
hax1 = gca ();
title(hax1, figure1_title, "fontsize", 7);
axis(hax1, [x1_lo x1_hi y1_lo y1_hi]);
xlabel(hax1, x1_lab, "fontsize", 6);
ylabel(hax1, y1_lab, "fontsize", 6);
grid(hax1, "on");
hold on;
h1 = plot(stimulus, result1, line_col_mark(1:numOfCurves), "markersize", 4, "linewidth", 1);
text((x1_hi+x1_lo)/2, (y1_hi-y1_lo)*0.9+y1_lo, operator_labels);
legend(hax1, par_names, "fontsize", 5, "location", "southeast");
print( [filename "_1.png"], "-dpng" );
hgsave( [filename "_1.ofig"] );
rstatus = xlswrite( [filename ".xlsx"], operator_labels, 'A1:N1')
rstatus = xlswrite( [filename ".xlsx"], figure1_title, 'A2:BZ2')
header = [{"Stimulus"} par_names];
rstatus = xlswrite( [filename ".xlsx"], header, 'A3:H3')
rstatus = xlswrite( [filename ".xlsx"], header, 'I3:P3')
% Export stimulus values and measurements as adjacent columns.
data_table = [stimulus' result1]
rstatus = xlswrite( [filename ".xlsx"], data_table, 'A4:H100')
data_table = [stimulus' result2]
rstatus = xlswrite( [filename ".xlsx"], data_table, 'I4:P100')
clear s;
