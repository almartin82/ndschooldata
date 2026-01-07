library(ndschooldata)

d <- fetch_enr(2024, tidy=TRUE)

print("=== Unique districts ===")
print(length(unique(d$district_id[!is.na(d$district_id)])))

print("=== Grade level counts ===")
print(table(d$grade_level))

print("=== Subgroup counts ===")
print(table(d$subgroup))

print("=== Type counts ===")
print(table(d$type))

print("=== Sample data ===")
print(head(d, 10))

print("=== Check for NA values ===")
print(colSums(is.na(d)))

print("=== Check pct column ===")
print(summary(d$pct))
print("Any Inf values:")
print(any(is.infinite(d$pct)))
print("Any NA values in pct:")
print(sum(is.na(d$pct)))

print("=== Row counts ===")
print(paste("Total rows:", nrow(d)))
print(paste("State rows:", sum(d$is_state)))
print(paste("District rows:", sum(d$is_district)))
print(paste("Campus rows:", sum(d$is_campus)))
