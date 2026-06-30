# 各自のパソコンでは setwd() の設定が必要になる場合があります。
# ただし、local環境と採点サーバーではパスが異なるため、
# setwd() を残したまま提出すると、採点時にエラーになって、0点になります。

# 作業前、メモリーを空にする
rm(list = ls())

library(tidyverse)

# Q1. UKgas を、時点 t と観測値 Y を持つ data.frame に変換
gas <- data.frame(
  t = 1:length(UKgas),
  Y = as.numeric(UKgas)
)

# Q2. 2次の多項式トレンドを推定
reg <- lm(Y ~ t + I(t^2), data = gas)

# Q3. トレンドの予測値を gas$trend として追加
gas$trend <- predict(reg)

# Q4. 四半期ラベル（Q1〜Q4）を gas$quarter として追加
gas$quarter <- factor(
  rep(c("Q1", "Q2", "Q3", "Q4"), times = length(UKgas) / 4),
  levels = c("Q1", "Q2", "Q3", "Q4")
)

# Q5. トレンド除去後の系列について、四半期ごとの平均（季節効果）を求める
seasonal_effect <- gas %>%
  mutate(detrended = Y - trend) %>%
  group_by(quarter) %>%
  summarise(seasonal = mean(detrended))

# Q6. 季節効果を gas に結合し、gas$seasonal を作成
gas <- gas %>%
  left_join(seasonal_effect, by = "quarter")

# Q7. 不規則変動 gas$irregular を作成
gas$irregular <- gas$Y - gas$trend - gas$seasonal

# Q8. 4成分（元データ・トレンド・季節変動・不規則変動）をまとめてプロット
library(patchwork)

p1 <- ggplot(gas, aes(t, Y)) +
  geom_line() +
  labs(title = "元データ", y = "Y")

p2 <- ggplot(gas, aes(t, trend)) +
  geom_line(color = "red") +
  labs(title = "トレンド", y = "T")

p3 <- ggplot(gas, aes(t, seasonal)) +
  geom_line(color = "#1B9E77") +
  labs(title = "季節変動", y = "S")

p4 <- ggplot(gas, aes(t, irregular)) +
  geom_line(color = "#7570B3") +
  labs(title = "不規則変動", y = "E")

plot_decomp <- (p1 | p2) / (p3 | p4)
plot_decomp
