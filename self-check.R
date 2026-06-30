# =====================================================
# HW4 自動チェックプログラム
# =====================================================
# このファイルは HW4.R と同じフォルダーで実行してください。

rm(list = ls())

suppressPackageStartupMessages(library(dplyr))

source_result <- tryCatch(
  {
    source("HW4.R")
    TRUE
  },
  error = function(e) {
    cat("HW4.R の実行中にエラーが発生しました:\n")
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

score <- 0

if (!source_result) {
  cat("\n===== チェック終了 =====\n")
  cat("総得点： 0 / 8\n")
  quit(status = 1)
}

# ------------------------------
# Q1 データ読み込み
# ------------------------------
score <- score + check(
  exists("co2_raw") &&
    exists("energy_raw") &&
    is.data.frame(co2_raw) &&
    is.data.frame(energy_raw) &&
    nrow(co2_raw) > 10000 &&
    nrow(energy_raw) > 10000,
  "Q1 正解：co2_raw と energy_raw が正しく作成されています",
  "Q1 不正解：co2_raw または energy_raw に問題があります"
)

# ------------------------------
# Q2 dim の保存
# ------------------------------
score <- score + check(
  exists("dim_co2") &&
    exists("dim_energy") &&
    identical(dim_co2, dim(co2_raw)) &&
    identical(dim_energy, dim(energy_raw)),
  "Q2 正解：dim_co2 と dim_energy は正しいです",
  "Q2 不正解：dim_co2 または dim_energy が正しくありません"
)

# ------------------------------
# Q3 co2_selected
# ------------------------------
co2_vars <- c(
  "country",
  "iso_code",
  "year",
  "co2",
  "co2_per_capita",
  "population",
  "gdp"
)

score <- score + check(
  exists("co2_selected") &&
    is.data.frame(co2_selected) &&
    all(co2_vars %in% names(co2_selected)) &&
    length(names(co2_selected)) == length(co2_vars) &&
    all(!is.na(co2_selected$iso_code)) &&
    all(co2_selected$iso_code != "") &&
    nrow(co2_selected %>% dplyr::count(iso_code, year) %>% dplyr::filter(n > 1)) == 0,
  "Q3 正解：co2_selected の構造は正しいです",
  "Q3 不正解：co2_selected の列、iso_code の処理、または key に問題があります"
)

# ------------------------------
# Q4 energy_selected
# ------------------------------
energy_vars <- c(
  "country_energy",
  "iso_code",
  "year",
  "primary_energy_consumption",
  "fossil_fuel_consumption",
  "fossil_share_energy",
  "renewables_consumption",
  "renewables_share_energy"
)

score <- score + check(
  exists("energy_selected") &&
    is.data.frame(energy_selected) &&
    all(energy_vars %in% names(energy_selected)) &&
    length(names(energy_selected)) == length(energy_vars) &&
    !("country" %in% names(energy_selected)) &&
    all(!is.na(energy_selected$iso_code)) &&
    all(energy_selected$iso_code != "") &&
    nrow(energy_selected %>% dplyr::count(iso_code, year) %>% dplyr::filter(n > 1)) == 0,
  "Q4 正解：energy_selected の構造は正しいです",
  "Q4 不正解：energy_selected の列、変数名、iso_code の処理、または key に問題があります"
)

# ------------------------------
# Q5 merged_data
# ------------------------------
merged_vars <- c(
  co2_vars,
  "country_energy",
  "primary_energy_consumption",
  "fossil_fuel_consumption",
  "fossil_share_energy",
  "renewables_consumption",
  "renewables_share_energy"
)

score <- score + check(
  exists("merged_data") &&
    is.data.frame(merged_data) &&
    all(merged_vars %in% names(merged_data)) &&
    nrow(merged_data) == nrow(co2_selected) &&
    nrow(merged_data %>% dplyr::count(iso_code, year) %>% dplyr::filter(n > 1)) == 0,
  "Q5 正解：merged_data は正しく結合されています",
  "Q5 不正解：merged_data の結合、列、行数、または key に問題があります"
)

# ------------------------------
# Q6 行数確認
# ------------------------------
score <- score + check(
  exists("n_co2_selected") &&
    exists("n_merged_data") &&
    n_co2_selected == nrow(co2_selected) &&
    n_merged_data == nrow(merged_data) &&
    n_co2_selected == n_merged_data,
  "Q6 正解：結合前後の行数確認は正しいです",
  "Q6 不正解：n_co2_selected または n_merged_data が正しくありません"
)

# ------------------------------
# Q7 欠損値確認
# ------------------------------
score <- score + check(
  exists("missing_summary") &&
    is.numeric(missing_summary) &&
    identical(names(missing_summary), names(merged_data)) &&
    isTRUE(all.equal(missing_summary, colSums(is.na(merged_data)))),
  "Q7 正解：missing_summary は正しいです",
  "Q7 不正解：missing_summary が正しくありません"
)

# ------------------------------
# Q8 selected_countries
# ------------------------------
target_countries <- c("Japan", "United States", "China", "Germany")

score <- score + check(
  exists("selected_countries") &&
    is.data.frame(selected_countries) &&
    all(selected_countries$country %in% target_countries) &&
    all(selected_countries$year >= 2000) &&
    all(target_countries %in% unique(selected_countries$country)) &&
    nrow(selected_countries) >= 80,
  "Q8 正解：selected_countries は正しく抽出されています",
  "Q8 不正解：selected_countries の国、年、または行数に問題があります"
)

cat("\n===== チェック終了 =====\n")
cat("総得点：", score, "/ 8\n")

if (score < 8) {
  quit(status = 1)
}
