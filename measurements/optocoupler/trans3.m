clc
pkg load instrument-control
pkg load io
clear s;
s = serialport('COM3', 115200)
filename = "optoelectronic_devices";
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
fig1_title = "I_{D} = f(U_{A-K}); I_{D-LED}=const";
y1_lab = "I_{D} [mA]";
y1_lo = 0;
y1_hi = 10;
x1_lab = "U_{A-K} [V]";
x1_lo = -3;
x1_hi = 0;
figure1_title = [fig1_title "     @" measurement_group "/" series_id "/" date "@"];
title(hax1, figure1_title, "fontsize", 7);
axis(hax1, [x1_lo x1_hi y1_lo y1_hi]);
xlabel(hax1, x1_lab, "fontsize", 6);
ylabel(hax1, y1_lab, "fontsize", 6);
grid(hax1, "on");
hold on;
par_names = [{"I_{ID-LED1}=30mA"}, {"I_{ID-LED2}=40mA"}, {"I_{ID-LED3}=50mA"}];
parameters = [ 30 40 50 ];
numOfCurves = columns(parameters)
stimulus = [ -9 -8 -7 -6 -5 -4 -3 -2 -1 0 ]
numOfPoints = columns(stimulus)
clear result1 data_table1 result2 data_table2
result1 = zeros(numOfPoints, numOfCurves);
result2 = zeros(numOfPoints, numOfCurves);
figure(1)
% Each parameter value produces one stimulus sweep.
for k = 1:numOfCurves
  fprintf(s, "CURR %f\n", parameters(k));
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
legend(hax1, par_names, "fontsize", 5, "location", "northwest");
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
