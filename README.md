# tlg_contest
debug telegram proj

======================================================
Telegram official coding competition for Android, iOS and JS developers starts tomorrow.

March 10-24, 125,000 USD in prizes.

The goal is to develop software for showing simple charts based on input data we provide. You can use either JavaScript, Android Java or iOS Swift.

Note: you may not use specialized charting libraries. All the code you submit must be written by you from scratch.

The criteria we’ll be using to define the winner are speed, efficiency and the size of the app.

The app should show 4 charts on one screen, based on the input data we will provide within the next 24 hours. We will announce how you can submit your finished work later in this channel.

Designs for the contest charts are attached below. We’ll distribute the 125,000 USD prize fund among the authors of the slickest apps in the final week of March.

Stay tuned for contest-related announcements in this channel.

Good luck!

======================================================

Use this JSON file as input data for the 5 charts. It contains a vector of JSON objects ('chart'), each representing a separate graph.

chart.columns – List of all data columns in the chart. Each column has its label at position 0, followed by values.
x values are UNIX timestamps in miliseconds.

chart.types – Chart types for each of the columns. Supported values:
"line" (line on the graph with linear interpolation),
"x" (x axis values for each of the charts at the corresponding positions).

chart.colors – Color for each line in 6-hex-digit format (e.g. "#AAAAAA").
chart.names – Names for each line.

======================================================


======================================================
