Announcing Stage 2 of the Chart Coding Competition for Android, iOS and JavaScript developers. 

Dates: April 7-15. The last submission will be accepted via @jobs_bot at 11:59 PM CET, April 15.

Prize budget: at least $150,000 to be distributed among the winners.

Who can participate: Everybody. However, those who went through Stage 1 will have significant competitive advantage. 

Goal: Build 5 graphs based on the input data we provide. In addition to line charts developed in Stage 1, we are inviting developers to support 3 new chart types: line charts with 2 Y axes, bar charts and percentage stacked area charts.

Those who aim for the first prize will also have to support the zoom in / zoom out feature and pie charts. Zooming in allows to expand each data point into another graph with a more detailed X-axis. For example, each point on a 365-day daily graph can be zoomed into a 24-hour graph on a 168-hour timeline, as shown on one of the video demonstrations below.

Here are the 5 graphs expected in the contest:

1. A line chart with 2 lines, exactly like in Stage 1 (Screenshot 1).

Bonus goal: A line chart with 2 lines that zooms into another line chart with 2 lines (Screenshot 2), as shown on the first video below.

2. A line chart with 2 lines and 2 Y axes (Screenshot 3). 

Bonus goal: A line chart with 2 Y axes that zooms into another line chart (Screenshot 2), as shown on the first video video demonstration below.

3. A stacked bar chart with 7 data types (Screenshots 5-6).

Bonus goal: A stacked bar chart with 7 data types which zooms into another stacked bar chart with 7 data types.

4. A daily bar chart with single data type (Screenshot 7).

Bonus goal: A daily bar chart with a single data type zooms into a line chart with 3 lines (the other two lines can represent values from 1 day and 1 week ago, as shown on Screenshot 8). Please see the second video demonstration below.

5. A percentage stacked area chart with 6 data types (Screenshots 9, 10).

Bonus goal: A percentage stacked area chart with 6 data types that zooms into a pie chart with average values for the selected period (Screenshot 11). See the third video demonstration below.

Note that you are not expected to implement the zooming transitions exactly as shown in the video demonstrations. They may be replaced with any slick and fast transition of your choice.

The Y-scale on line graphs should start with the lowest visible value (Screenshot 4). A long tap on any data filter should uncheck all other filters. 

As in Stage 1, we will provide input data for all 5 graphs within the next 24 hours. We’ll also be updating you on the testing process, which, as mentioned before, will be public.

Good luck!

================================

When selecting the winners of Stage 2, we will consider speed, attention to detail and functionality. 

We will test and potentially award all developers that correctly implemented the 5 chart types described above. 

Some developers may choose not to implement the bonus goal, focusing on speed and usability of the main graphs instead. Others may opt to aim for the big prize. Either strategy has its good points.

Have fun finding the best approach. We’ll be back with the input data tomorrow.

=================================

Please find the input data for Stage 2 (https://t.me/contest/59) in the archive below. There are 5 folders there, each containing a .json for the corresponding graph (“overview.json”) and 12 subfolders (“YYYY-MM”) with "zoomed" graphs for each day of each month (“DD.json”). The subfolders with daily graphs are required only for those aiming to achieve the bonus goal. 

Compared to Stage 1 (https://t.me/contest/6), we added a few new parameters and chart types into the JSONs. 

chart.columns – List of all data columns in the chart. Each column has its label at position 0, followed by values.
x values are UNIX timestamps in milliseconds.

chart.types – Chart types for each of the columns. Supported values:
"line",
"area”, 
"bar”, 
"x" (x axis values for each of the charts at the corresponding positions).

chart.colors – Color for each variable in 6-hex-digit format (e.g. "#AAAAAA").
chart.names – Name for each variable.
chart.percentage – true for percentage based values.
chart.stacked – true for values stacking on top of each other. 
chart.y_scaled – true for charts with 2 Y axes.


=====================================

Note that in the input data provided above, the “zoomed” per hour data for each day (Charts 1, 2 and 3) can be accompanied by data for up to 6 other days – typically, 3 days preceding and 3 days following the requested day. This structure allow to display the bottom navigation bar in the “zoomed” mode using just one data file.

For those who don’t need this optimization, we prepared the same data with no additional days included when zooming. See the archive below.

(All of this is relevant only for the developers who are aiming for the bonus goal. The rest can just use the "overview.js" files.)

====================================

Earlier today our designers fixed glitches in Video 1 and Screenshot 3. To make up for their mistake for you, they came up with color descriptions used in all the screenshots. They hope you might find these descriptions useful, particularly those for colors with opacity parameters.

https://telegra.ph/JS-Design-Specification-04-07
https://telegra.ph/Android-Design-Specification-04-07
https://telegra.ph/iOS-Design-Specification-04-07

