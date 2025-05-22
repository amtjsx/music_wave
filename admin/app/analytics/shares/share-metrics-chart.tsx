"use client";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

// Sample data
const data = [
  { date: "05/01", shares: 1200, clicks: 800 },
  { date: "05/02", shares: 1300, clicks: 950 },
  { date: "05/03", shares: 1400, clicks: 1100 },
  { date: "05/04", shares: 1350, clicks: 900 },
  { date: "05/05", shares: 1500, clicks: 1050 },
  { date: "05/06", shares: 1600, clicks: 1200 },
  { date: "05/07", shares: 1750, clicks: 1350 },
  { date: "05/08", shares: 1800, clicks: 1400 },
  { date: "05/09", shares: 1850, clicks: 1450 },
  { date: "05/10", shares: 1700, clicks: 1300 },
  { date: "05/11", shares: 1600, clicks: 1200 },
  { date: "05/12", shares: 1550, clicks: 1150 },
  { date: "05/13", shares: 1650, clicks: 1250 },
  { date: "05/14", shares: 1700, clicks: 1300 },
  { date: "05/15", shares: 1800, clicks: 1400 },
  { date: "05/16", shares: 1850, clicks: 1450 },
  { date: "05/17", shares: 1900, clicks: 1500 },
  { date: "05/18", shares: 1950, clicks: 1550 },
  { date: "05/19", shares: 2000, clicks: 1600 },
  { date: "05/20", shares: 2100, clicks: 1700 },
  { date: "05/21", shares: 2200, clicks: 1800 },
  { date: "05/22", shares: 2300, clicks: 1900 },
  { date: "05/23", shares: 2400, clicks: 2000 },
  { date: "05/24", shares: 2500, clicks: 2100 },
  { date: "05/25", shares: 2600, clicks: 2200 },
  { date: "05/26", shares: 2700, clicks: 2300 },
  { date: "05/27", shares: 2800, clicks: 2400 },
  { date: "05/28", shares: 2900, clicks: 2500 },
  { date: "05/29", shares: 3000, clicks: 2600 },
  { date: "05/30", shares: 3100, clicks: 2700 },
];

export function ShareMetricsChart() {
  return (
    <ResponsiveContainer width="100%" height={350}>
      <LineChart
        data={data}
        margin={{
          top: 5,
          right: 30,
          left: 20,
          bottom: 5,
        }}
      >
        <CartesianGrid strokeDasharray="3 3" opacity={0.2} />
        <XAxis
          dataKey="date"
          tick={{ fontSize: 12 }}
          tickMargin={10}
          tickFormatter={(value, index) => (index % 5 === 0 ? value : "")}
        />
        <YAxis tick={{ fontSize: 12 }} tickMargin={10} />
        <Tooltip
          contentStyle={{
            backgroundColor: "rgba(17, 17, 17, 0.8)",
            border: "none",
            borderRadius: "4px",
            color: "#fff",
            fontSize: "12px",
          }}
        />
        <Legend wrapperStyle={{ fontSize: "12px", paddingTop: "10px" }} />
        <Line
          type="monotone"
          dataKey="shares"
          stroke="#9333ea"
          strokeWidth={2}
          activeDot={{ r: 6 }}
          dot={false}
        />
        <Line
          type="monotone"
          dataKey="clicks"
          stroke="#60a5fa"
          strokeWidth={2}
          dot={false}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
