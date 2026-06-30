# R-Programming-HW4-Template

今回の課題は、2つの公開データを読み込み、国別・年別データを結合する練習である。

課題はすべて、`HW4.R` に記載してください。今回の課題に関係ないものが記載されても、採点されません。

使用するデータは以下の2つである。

- OWID CO2 and Greenhouse Gas Emissions

```r
co2_raw <- read.csv("https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv")
```

- OWID Energy Dataset

```r
energy_raw <- read.csv("https://raw.githubusercontent.com/owid/energy-data/master/owid-energy-data.csv")
```

可能な限り、パイプ演算子 `%>%` を使用すること。


## 課題

1. 上記2つのデータを読み込み、それぞれ `co2_raw`、`energy_raw` として保存しなさい。

2. `co2_raw` と `energy_raw` の行数・列数を確認し、それぞれ `dim_co2`、`dim_energy` として保存しなさい。

3. `co2_raw` から `iso_code` が空ではない行だけを残し、以下の変数だけを抽出して、`co2_selected` として保存しなさい。

| 変数名 | 内容 |
|:---|:---|
| country | 国名 |
| iso_code | 国コード |
| year | 年 |
| co2 | CO2排出量 |
| co2_per_capita | 1人当たりCO2排出量 |
| population | 人口 |
| gdp | GDP |

4. `energy_raw` から `iso_code` が空ではない行だけを残し、以下の変数だけを抽出して、`energy_selected` として保存しなさい。ただし、`country` は `country_energy` という変数名に変更すること。

| 変数名 | 内容 |
|:---|:---|
| country_energy | 国名 |
| iso_code | 国コード |
| year | 年 |
| primary_energy_consumption | 一次エネルギー消費 |
| fossil_fuel_consumption | 化石燃料消費 |
| fossil_share_energy | 化石燃料比率 |
| renewables_consumption | 再生可能エネルギー消費 |
| renewables_share_energy | 再生可能エネルギー比率 |


5. `co2_selected` と `energy_selected` を、`iso_code` と `year` を key として結合し、`merged_data` として保存しなさい。結合には `left_join()` (co2データを基準に)を使い、`relationship = "one-to-one"` を指定すること。


6. 結合前後の行数を確認し、それぞれ `n_co2_selected`、`n_merged_data` として保存しなさい。


7. `merged_data` の欠損値の数を列ごとに確認し、`missing_summary` として保存しなさい。


8. `merged_data` から、日本、アメリカ、中国、ドイツの4か国、かつ2000年以降のデータだけを抽出し、`selected_countries` として保存しなさい。


## 提出時に必ず存在している object

採点のため、以下の object 名を必ず使用すること。

```r
co2_raw
energy_raw
dim_co2
dim_energy
co2_selected
energy_selected
merged_data
n_co2_selected
n_merged_data
missing_summary
selected_countries
```

