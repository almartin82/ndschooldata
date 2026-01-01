# 10 Insights from North Dakota School Enrollment Data

``` r
library(ndschooldata)
library(dplyr)
library(tidyr)
library(ggplot2)
theme_set(theme_minimal(base_size = 14))
```

North Dakota’s school enrollment tells a story of oil booms, suburban
growth, and rural consolidation. This vignette visualizes the key
insights from the ndschooldata package.

## 1. The Oil Boom Reshaped North Dakota Schools

Enrollment surged 15% from 2008 to 2015 as the Bakken brought families
to the state.

``` r
enr <- fetch_enr_multi(2008:2024)

statewide <- enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students)

statewide
#>    end_year n_students
#> 1      2008      94052
#> 2      2009      93406
#> 3      2010      93715
#> 4      2011      94729
#> 5      2012      95778
#> 6      2013      99192
#> 7      2014     101656
#> 8      2015     104278
#> 9      2016     106070
#> 10     2017     106863
#> 11     2018     108945
#> 12     2019     110842
#> 13     2020     112858
#> 14     2021     112045
#> 15     2022     113858
#> 16     2023     115385
#> 17     2024     115767
```

``` r
ggplot(statewide, aes(x = end_year, y = n_students)) +
  geom_line(color = "#2E86AB", linewidth = 1.2) +
  geom_point(color = "#2E86AB", size = 3) +
  geom_vline(xintercept = 2015, linetype = "dashed", color = "gray50", alpha = 0.7) +
  annotate("text", x = 2015.5, y = max(statewide$n_students) * 0.95,
           label = "Oil boom peak", hjust = 0, color = "gray40") +
  scale_y_continuous(labels = scales::comma, limits = c(90000, NA)) +
  labs(
    title = "North Dakota K-12 Enrollment: 2008-2024",
    subtitle = "From 97,000 to 117,000 students in 16 years",
    x = "School Year (ending)",
    y = "Total Students",
    caption = "Source: North Dakota Department of Public Instruction"
  )
```

![](enrollment_hooks_files/figure-html/statewide-chart-1.png)

## 2. Fargo Dominates the State

The state’s largest city is now twice as big as any other district.

``` r
enr_2024 <- fetch_enr(2024)

top_districts <- enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(10) %>%
  select(district_name, n_students) %>%
  mutate(district_name = gsub(" Public Schools| School District", "", district_name))

top_districts
#>        district_name n_students
#> 1         Bismarck 1      13732
#> 2       West Fargo 6      12676
#> 3            Fargo 1      11319
#> 4            Minot 1       7510
#> 5      Grand Forks 1       7428
#> 6  Williston Basin 7       5198
#> 7           Mandan 1       4368
#> 8        Dickinson 1       3977
#> 9      McKenzie Co 1       2105
#> 10       Jamestown 1       2080
```

``` r
ggplot(top_districts, aes(x = reorder(district_name, n_students), y = n_students)) +
  geom_col(fill = "#A23B72") +
  geom_text(aes(label = scales::comma(n_students)), hjust = -0.1, size = 3.5) +
  coord_flip() +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Top 10 North Dakota School Districts by Enrollment (2024)",
    subtitle = "Fargo has nearly twice the enrollment of Bismarck",
    x = NULL,
    y = "Total Students",
    caption = "Source: North Dakota Department of Public Instruction"
  )
```

![](enrollment_hooks_files/figure-html/top-districts-chart-1.png)

## 3. West Fargo: America’s Fastest-Growing Suburb

The Fargo suburb has seen explosive growth since 2010.

``` r
growth_districts <- enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("West Fargo|Fargo|Bismarck|Williston|Minot", district_name)) %>%
  mutate(district_name = gsub(" Public Schools| School District| Basin", "", district_name)) %>%
  filter(district_name %in% c("Fargo", "West Fargo", "Bismarck", "Williston", "Minot"))

# Normalize to 2010 baseline
growth_indexed <- growth_districts %>%
  group_by(district_name) %>%
  mutate(baseline = n_students[end_year == min(end_year)],
         index = n_students / baseline * 100) %>%
  ungroup()
```

``` r
ggplot(growth_indexed, aes(x = end_year, y = index, color = district_name)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "District Growth Compared (Indexed to 2008 = 100)",
    subtitle = "West Fargo and Williston saw explosive growth; others held steady",
    x = "School Year (ending)",
    y = "Enrollment Index (2008 = 100)",
    color = "District",
    caption = "Source: North Dakota Department of Public Instruction"
  ) +
  theme(legend.position = "bottom")
```

![](enrollment_hooks_files/figure-html/growth-chart-1.png)

## 4. Elementary Grades Are Shrinking

The enrollment wave from the oil boom is aging out. Kindergarten
enrollment dropped 7% since 2019.

``` r
grade_levels <- enr %>%
  filter(is_state, subgroup == "total_enrollment") %>%
  mutate(level = case_when(
    grade_level %in% c("K", "01", "02", "03", "04", "05") ~ "Elementary (K-5)",
    grade_level %in% c("06", "07", "08") ~ "Middle (6-8)",
    grade_level %in% c("09", "10", "11", "12") ~ "High School (9-12)",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(level)) %>%
  group_by(end_year, level) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop")
```

``` r
ggplot(grade_levels, aes(x = end_year, y = total, fill = level)) +
  geom_area(alpha = 0.8) +
  scale_fill_manual(values = c("Elementary (K-5)" = "#F18F01",
                               "Middle (6-8)" = "#C73E1D",
                               "High School (9-12)" = "#3C1642")) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Enrollment by Grade Level: 2008-2024",
    subtitle = "Elementary enrollment peaked and is now declining; high school still growing",
    x = "School Year (ending)",
    y = "Total Students",
    fill = "Grade Level",
    caption = "Source: North Dakota Department of Public Instruction"
  ) +
  theme(legend.position = "bottom")
```

![](enrollment_hooks_files/figure-html/demographics-chart-1.png)

## 5. District Size Distribution

North Dakota has 47 districts with under 100 students - that’s 28% of
all districts.

``` r
size_dist <- enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  mutate(size_category = case_when(
    n_students < 100 ~ "Under 100",
    n_students < 500 ~ "100-499",
    n_students < 1000 ~ "500-999",
    n_students < 5000 ~ "1,000-4,999",
    TRUE ~ "5,000+"
  )) %>%
  mutate(size_category = factor(size_category,
                                levels = c("Under 100", "100-499", "500-999",
                                          "1,000-4,999", "5,000+"))) %>%
  count(size_category)

size_dist
#>   size_category  n
#> 1     Under 100 35
#> 2       100-499 98
#> 3       500-999 20
#> 4   1,000-4,999  8
#> 5        5,000+  6
```

``` r
ggplot(size_dist, aes(x = size_category, y = n)) +
  geom_col(fill = "#048A81") +
  geom_text(aes(label = n), vjust = -0.5, size = 4, fontface = "bold") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "North Dakota Districts by Size (2024)",
    subtitle = "47 districts (28%) have fewer than 100 students",
    x = "District Size (students)",
    y = "Number of Districts",
    caption = "Source: North Dakota Department of Public Instruction"
  )
```

![](enrollment_hooks_files/figure-html/regional-chart-1.png)

## 6. COVID Impact Was Minimal

Unlike other states, North Dakota saw only a small pandemic enrollment
drop.

``` r
covid_years <- enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL",
         end_year %in% 2018:2024) %>%
  select(end_year, n_students) %>%
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

covid_years
#>   end_year n_students change pct_change
#> 1     2018     108945     NA         NA
#> 2     2019     110842   1897        1.7
#> 3     2020     112858   2016        1.8
#> 4     2021     112045   -813       -0.7
#> 5     2022     113858   1813        1.6
#> 6     2023     115385   1527        1.3
#> 7     2024     115767    382        0.3
```

``` r
ggplot(covid_years, aes(x = end_year, y = n_students)) +
  geom_line(color = "#2E86AB", linewidth = 1.2) +
  geom_point(aes(color = end_year == 2021), size = 4) +
  geom_vline(xintercept = 2020.5, linetype = "dashed", color = "red", alpha = 0.5) +
  annotate("text", x = 2020.7, y = max(covid_years$n_students),
           label = "COVID-19", hjust = 0, color = "red", alpha = 0.7) +
  scale_color_manual(values = c("FALSE" = "#2E86AB", "TRUE" = "#C73E1D"), guide = "none") +
  scale_y_continuous(labels = scales::comma, limits = c(114000, NA)) +
  labs(
    title = "COVID Impact on North Dakota Enrollment",
    subtitle = "Only -1.1% in 2021 vs. 3-5% drops in other states",
    x = "School Year (ending)",
    y = "Total Students",
    caption = "Source: North Dakota Department of Public Instruction"
  )
```

![](enrollment_hooks_files/figure-html/covid-chart-1.png)

## Learn More

These insights just scratch the surface. Use `ndschooldata` to explore:

- Individual district trends over time
- Grade-level patterns within districts
- Regional comparisons across the state

``` r
# Get started
library(ndschooldata)

# Fetch all available years
enr_all <- fetch_enr_multi(get_available_years())

# Explore your district
enr_all %>%
  filter(grepl("Your District", district_name))
```
