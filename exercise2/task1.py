import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sqlalchemy import create_engine

engine = create_engine('sqlite:////home/ossi/Downloads/database.sqlite')

def do_plot(table_name: str):
    df = (pd.read_sql_table(table_name, engine, parse_dates=['Date'])[["created_at"]]
               .sort_values("created_at")
               .reset_index())
    df["count"] = df.index + 1
    df["year"] = pd.DatetimeIndex(df["created_at"]).year
    df = df.groupby(["year"], as_index=False).count()

    df["count_cumulative"] = df["count"].cumsum()

    years = sorted(df["year"].unique())
    max_year = years[-1]
    for year in range(max_year + 1, max_year + 4):
        years.append(year)

    df.plot(x="year", y="count", kind="line", title=table_name, xticks=np.arange(2021, 2025, 1))
    plt.show()
    df.plot(x="year", y="count_cumulative", kind="line", xticks=np.arange(years[0], years[-1] + 1, 1))
    plt.suptitle("cumulative_" + table_name)

    z = np.polyfit(df["year"], df["count_cumulative"], 1)
    p = np.poly1d(z)

    plt.title(f"y={z[0]:.5f}x{z[1]:+.5f}")

    # add trendline to plot
    plt.plot(years, p(years), linestyle="--")

    plt.show()

do_plot("users")
do_plot("posts")
do_plot("comments")
