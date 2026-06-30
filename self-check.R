# =====================================================
# HW5 自動チェックプログラム
# =====================================================
# このファイルは HW5.R と同じフォルダーに置いてください。

rm(list = ls())

if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}

suppressPackageStartupMessages(library(dplyr))

source_result <- tryCatch(
  {
    source("HW5.R")
    TRUE
  },
  error = function(e) {
    cat("HW5.R の実行中にエラーが発生しました:\n")
    cat(conditionMessage(e), "\n")
    FALSE
  }
)

check <- function(cond, msg_ok, msg_ng) {
  cond_eval <- tryCatch(isTRUE(cond), error = function(e) FALSE)
  if (cond_eval) {
    cat(msg_ok, "\n")
    return(1)
  } else {
    cat(msg_ng, "\n")
    return(0)
  }
}

# 数値が（許容誤差つきで）一致するか
approx_equal <- function(a, b, tol = 1e-6) {
  tryCatch(
    isTRUE(all.equal(as.numeric(a), as.numeric(b), tolerance = tol)),
    error = function(e) FALSE
  )
}

score <- 0

if (!source_result) {
  cat("\n===== チェック終了 =====\n")
  cat("総得点： 0 / 8\n")
  quit(status = 1)
}

# ------------------------------
# 参照解（standard answer）を内部で計算
# ------------------------------
.n           <- length(UKgas)
.ref_t       <- 1:.n
.ref_Y       <- as.numeric(UKgas)
.ref_reg     <- lm(.ref_Y ~ .ref_t + I(.ref_t^2))
.ref_trend   <- as.numeric(predict(.ref_reg))
.ref_quarter <- rep(c("Q1", "Q2", "Q3", "Q4"), times = .n / 4)
.ref_detr    <- .ref_Y - .ref_trend
.ref_seas_by <- tapply(.ref_detr, .ref_quarter, mean)        # 四半期ごとの平均
.ref_seasonal <- as.numeric(.ref_seas_by[.ref_quarter])
.ref_irreg   <- .ref_Y - .ref_trend - .ref_seasonal

# ------------------------------
# Q1 gas（t, Y）
# ------------------------------
score <- score + check(
  exists("gas") &&
    is.data.frame(gas) &&
    all(c("t", "Y") %in% names(gas)) &&
    nrow(gas) == .n &&
    approx_equal(gas$t, .ref_t) &&
    approx_equal(gas$Y, .ref_Y),
  "Q1 正解：gas（t, Y）が正しく作成されています",
  "Q1 不正解：gas の作成（t, Y）に問題があります"
)

# ------------------------------
# Q2 reg（2次の多項式トレンド）
# ------------------------------
score <- score + check(
  exists("reg") &&
    inherits(reg, "lm") &&
    length(coef(reg)) == 3 &&                       # 切片 + t + t^2
    approx_equal(as.numeric(fitted(reg)), .ref_trend),
  "Q2 正解：reg は2次の多項式トレンドです",
  "Q2 不正解：reg のモデル（2次の多項式）に問題があります"
)

# ------------------------------
# Q3 gas$trend
# ------------------------------
score <- score + check(
  exists("gas") &&
    "trend" %in% names(gas) &&
    approx_equal(gas$trend, .ref_trend),
  "Q3 正解：gas$trend は正しいです",
  "Q3 不正解：gas$trend が正しくありません"
)

# ------------------------------
# Q4 gas$quarter
# ------------------------------
score <- score + check(
  exists("gas") &&
    "quarter" %in% names(gas) &&
    is.factor(gas$quarter) &&
    setequal(levels(gas$quarter), c("Q1", "Q2", "Q3", "Q4")) &&
    all(as.character(gas$quarter) == .ref_quarter),
  "Q4 正解：gas$quarter は正しいです",
  "Q4 不正解：gas$quarter（四半期ラベル）が正しくありません"
)

# ------------------------------
# Q5 seasonal_effect（quarter, seasonal）
# ------------------------------
q5_ok <- FALSE
if (exists("seasonal_effect") &&
    is.data.frame(seasonal_effect) &&
    all(c("quarter", "seasonal") %in% names(seasonal_effect)) &&
    nrow(seasonal_effect) == 4) {
  idx <- match(c("Q1", "Q2", "Q3", "Q4"), as.character(seasonal_effect$quarter))
  q5_ok <- !any(is.na(idx)) &&
    approx_equal(seasonal_effect$seasonal[idx],
                 as.numeric(.ref_seas_by[c("Q1", "Q2", "Q3", "Q4")]))
}
score <- score + check(
  q5_ok,
  "Q5 正解：seasonal_effect は正しいです",
  "Q5 不正解：seasonal_effect（quarter, seasonal）が正しくありません"
)

# ------------------------------
# Q6 gas$seasonal
# ------------------------------
score <- score + check(
  exists("gas") &&
    "seasonal" %in% names(gas) &&
    approx_equal(gas$seasonal, .ref_seasonal),
  "Q6 正解：gas$seasonal は正しいです",
  "Q6 不正解：gas$seasonal が正しくありません"
)

# ------------------------------
# Q7 gas$irregular（Y = trend + seasonal + irregular）
# ------------------------------
score <- score + check(
  exists("gas") &&
    "irregular" %in% names(gas) &&
    approx_equal(gas$irregular, .ref_irreg) &&
    approx_equal(gas$Y, gas$trend + gas$seasonal + gas$irregular),
  "Q7 正解：gas$irregular は正しいです",
  "Q7 不正解：gas$irregular が正しくありません"
)

# ------------------------------
# Q8 plot_decomp（図オブジェクト）
# ------------------------------
score <- score + check(
  exists("plot_decomp") &&
    inherits(plot_decomp, "ggplot"),               # patchwork も ggplot を継承
  "Q8 正解：plot_decomp（図）が作成されています",
  "Q8 不正解：plot_decomp が作成されていません"
)

cat("\n===== チェック終了 =====\n")
cat("総得点：", score, "/ 8\n")

if (score < 8) {
  quit(status = 1)
}
