"use client"

import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from "recharts"

// Sample data
const data = [
  { name: "Twitter", value: 42 },
  { name: "Facebook", value: 21.3 },
  { name: "Instagram", value: 18.8 },
  { name: "Direct Link", value: 17.9 },
]

const COLORS = ["#60a5fa", "#3b82f6", "#ec4899", "#6b7280"]

export function PlatformDistributionChart() {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <PieChart>
        <Pie
          data={data}
          cx="50%"
          cy="50%"
          labelLine={false}
          outerRadius={100}
          fill="#8884d8"
          dataKey="value"
          label={({ name, percent }) => `${name} ${(percent * 100).toFixed(1)}%`}
        >
          {data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip
          formatter={(value) => `${value}%`}
          contentStyle={{
            backgroundColor: "rgba(17, 17, 17, 0.8)",
            border: "none",
            borderRadius: "4px",
            color: "#fff",
            fontSize: "12px",
          }}
        />
        <Legend wrapperStyle={{ fontSize: "12px", paddingTop: "20px" }} />
      </PieChart>
    </ResponsiveContainer>
  )
}
