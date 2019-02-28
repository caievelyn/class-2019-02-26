library(tidyverse)
library(dplyr)
library(readxl)
library(janitor)
library(devtools)
library(gt)

download.file("https://registrar.fas.harvard.edu/files/fas-registrar/files/class_enrollment_summary_by_term_2.28.19.xlsx",
              destfile = "reg_2019.xlsx",
              mode = "wb")
download.file("https://registrar.fas.harvard.edu/files/fas-registrar/files/class_enrollment_summary_by_term_03.06.18.xlsx",
              destfile = "reg_2018.xlsx",
              mode = "wb")

x_2019 <- read_xlsx("reg_2019.xlsx", skip = 3) %>%
  clean_names() %>%
  filter(!is.na(course_name)) %>%
  select(course_title, course_name, u_grad, course_id)
  
x_2018 <- read_xlsx("reg_2018.xlsx", skip = 2) %>%
  clean_names() %>%
  filter(!is.na(course_name)) %>%
  select(course_title, course_name, u_grad, course_id)

all <- inner_join(x_2019, x_2018, by = "course_id", suffix = c(".2019", ".2018"))

all %>%
  select(course_title.2019, course_name.2019, u_grad.2018, u_grad.2019) %>%
  mutate(Change = -(u_grad.2019 - u_grad.2018)) %>%
  arrange(desc(Change)) %>%
  slice(1:10) %>%
  mutate(Change = -Change) %>%
  gt() %>%
  tab_header(title = "Biggest Enrollment Decreases in Spring 2019") %>%
  tab_source_note(
    source_note = "Data from the Harvard Registrar") %>%
  cols_label("course_title.2019" = "Number",
             "course_name.2019" = "Name",
             "u_grad.2019" = "2019",
             "u_grad.2018" = "2018")