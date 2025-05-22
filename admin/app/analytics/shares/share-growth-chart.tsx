"use client"

import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts"

// Sample data
const data = [
  { month: "Jan", shares: 4000, growth: 12 },
  { month: "Feb", shares: 4500, growth: 12.5 },
  { month: "Mar", shares: 5100, growth: 13.3 },
  { month: "Apr", shares: 5800, growth: 13.7 },
  { month: "May", shares: 6500, growth: 12.1 },
  { month: "Jun", shares: 7200, growth: 10.8 },
  { month: "Jul", shares: 8000, growth: 11.1 },
  { month: "Aug", shares: 8900, growth: 11.3 },
  { month: "Sep", shares: 9800, growth: 10.1 },
  { month: "Oct", shares: 10700, growth: 9.2 },
  { month: "Nov", shares: 11500, growth: 7.5 },
  { month: "Dec", shares: 12400, growth: 7.8 },
]

export function ShareGrowthChart() {
  return (
    <ResponsiveContainer width="100%" height={350}>
      <BarChart
        data={data}
        margin={{
          top: 5,
          right: 30,
          left: 20,
          bottom: 5,
        }}
      >
        <CartesianGrid strokeDasharray="3 3" opacity={0.2} />
        <XAxis dataKey="month" tick={{ fontSize: 12 }} tickMargin={10} />
        <YAxis yAxisId="left" tick={{ fontSize: 12 }} tickMargin={10} />
        <YAxis yAxisId="right" orientation="right" tick={{ fontSize: 12 }} tickMargin={10} />
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
        <Bar yAxisId="left" dataKey="shares" fill="#9333ea" radius={[4, 4, 0, 0]} />
        <Bar yAxisId="right" dataKey="growth" fill="#60a5fa" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  )
}
