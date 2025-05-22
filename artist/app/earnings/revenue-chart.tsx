"use client";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  type TooltipProps,
} from "recharts";
import { Card, CardContent } from "@/components/ui/card";

// Sample data
const weekData = [
  { name: "Mon", revenue: 1200 },
  { name: "Tue", revenue: 940 },
  { name: "Wed", revenue: 1290 },
  { name: "Thu", revenue: 1580 },
  { name: "Fri", revenue: 1890 },
  { name: "Sat", revenue: 2390 },
  { name: "Sun", revenue: 2490 },
];

const monthData = [
  { name: "Week 1", revenue: 4200 },
  { name: "Week 2", revenue: 3800 },
  { name: "Week 3", revenue: 5100 },
  { name: "Week 4", revenue: 4600 },
];

const yearData = [
  { name: "Jan", revenue: 12500 },
  { name: "Feb", revenue: 10800 },
  { name: "Mar", revenue: 14200 },
  { name: "Apr", revenue: 13500 },
  { name: "May", revenue: 15800 },
  { name: "Jun", revenue: 16200 },
  { name: "Jul", revenue: 18900 },
  { name: "Aug", revenue: 19500 },
  { name: "Sep", revenue: 21000 },
  { name: "Oct", revenue: 22400 },
  { name: "Nov", revenue: 24100 },
  { name: "Dec", revenue: 25600 },
];

const CustomTooltip = ({
  active,
  payload,
  label,
}: TooltipProps<number, string>) => {
  if (active && payload && payload.length) {
    return (
      <Card>
        <CardContent className="p-2">
          <p className="text-sm font-medium">{`${label}`}</p>
          <p className="text-sm text-purple-600">{`$${payload[0].value?.toLocaleString()}`}</p>
        </CardContent>
      </Card>
    );
  }

  return null;
};

export function RevenueChart({ timeframe }: { timeframe: string }) {
  // Select data based on timeframe
  const data =
    timeframe === "week"
      ? weekData
      : timeframe === "month"
      ? monthData
      : yearData;

  return (
    <div className="h-[300px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <LineChart
          data={data}
          margin={{
            top: 5,
            right: 10,
            left: 10,
            bottom: 5,
          }}
        >
          <CartesianGrid strokeDasharray="3 3" stroke="#374151" opacity={0.1} />
          <XAxis
            dataKey="name"
            stroke="#6B7280"
            fontSize={12}
            tickLine={false}
            axisLine={{ stroke: "#374151", opacity: 0.2 }}
          />
          <YAxis
            stroke="#6B7280"
            fontSize={12}
            tickLine={false}
            axisLine={{ stroke: "#374151", opacity: 0.2 }}
            tickFormatter={(value) => `$${value}`}
          />
          <Tooltip content={<CustomTooltip />} />
          <Line
            type="monotone"
            dataKey="revenue"
            stroke="#9333EA"
            strokeWidth={2}
            dot={{ r: 4, fill: "#9333EA", strokeWidth: 0 }}
            activeDot={{ r: 6, fill: "#9333EA", strokeWidth: 0 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
