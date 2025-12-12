# can attach pkgs

    Code
      attach_pkgs(c("knitr", "readr"))

# can fail on a single pkg

    Code
      attach_pkgs(c("potato"))
    Condition
      Error in `attach_pkgs()`:
      ! Package(s) could not be attached:
      * potato

# can fail on multiple pkgs

    Code
      attach_pkgs(c("potato", "bloopy"))
    Condition
      Error in `attach_pkgs()`:
      ! Package(s) could not be attached:
      * potato
      * bloopy

---

    Code
      attach_pkgs(c("potato", "readr"))
    Condition
      Error in `attach_pkgs()`:
      ! Package(s) could not be attached:
      * potato

