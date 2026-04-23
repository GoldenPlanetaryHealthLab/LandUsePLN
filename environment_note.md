# Environment and Dependency Management

This project uses a layered environment management strategy to ensure reproducibility, portability, and stability across HPC systems.

Overview of the Stack

We separate responsibilities across three layers:

HPC / OS Layer
  - Cluster operating system (glibc, kernel, scheduler)
User Runtime Layer (mamba)
  - R
  - Python
  - GDAL, GEOS, PROJ (geospatial system libraries)
Project Package Layer
  - renv (R packages)
  - uv (Python packages)

Each layer solves a different problem:

* mamba provides a consistent, user-controlled runtime with all required compiled dependencies.
* renv tracks R package dependencies at the project level.
* uv tracks Python dependencies at the project level.

This separation avoids common issues where tools compete to manage the same dependencies.

⸻

Why This Setup Exists

This project originated from a non-reproducible workflow that:

* relied on manual downloads
* used an untracked local environment
* had implicit system dependencies (GDAL, R, etc.)
* could not be reliably re-run on another machine

The goal of this package is to convert that workflow into a fully reproducible data pipeline, including:

* explicit dependency tracking
* deterministic builds
* portable execution on HPC systems

⸻

Challenges Encountered

During development, several environment management challenges were identified.

1. System vs Project Dependencies

Geospatial workflows depend heavily on compiled system libraries such as:

* GDAL
* GEOS
* PROJ

These are not typical R or Python packages and must be installed at the system/runtime level.

Solution:
Use mamba (conda-forge) to manage these dependencies in a consistent, user-controlled environment.

⸻

2. Mixing Package Managers

Attempting to use multiple tools to manage the same layer (e.g., R packages via both conda and CRAN) leads to:

* conflicting versions
* ABI mismatches
* unpredictable runtime behavior

Example failure mode:

* rmarkdown installed via conda works
* rmarkdown installed via another tool fails or behaves differently

Solution:
Each layer has a single owner:

* mamba → system/runtime dependencies
* renv → R packages
* uv → Python packages

⸻

3. HPC Constraints (glibc and System Libraries)

Some tools (e.g., newer Rust-based package managers) require newer versions of system libraries such as glibc.

On HPC systems, these are:

* controlled by the cluster
* not user-upgradable
* often older than modern Linux distributions

Observed issue:

GLIBC_2.29 not found
GLIBC_2.32 not found

Implication:
Even with mamba, not all binaries are portable to the cluster environment.

Solution:

* Avoid tools that depend on newer system libraries than the cluster provides
* Prefer tools that are compatible with older, stable Linux baselines

⸻

4. Experimental Tooling Instability

We evaluated newer tools for R dependency management (e.g., rv, uvr), but encountered issues such as:

* package installation failures (rmarkdown failing under rv)
* incompatibility with cluster system libraries (uvr and glibc)
* inconsistent behavior compared to standard R workflows

Conclusion:
These tools are promising but not yet robust enough for this environment.

⸻

Why We Use renv for R

We ultimately chose renv because it:

* is widely used in the R ecosystem
* integrates cleanly with CRAN workflows
* does not require non-standard system dependencies
* works reliably on HPC systems

This allows us to maintain:

* a project-specific R library
* a lockfile (renv.lock) for reproducibility
* compatibility with standard R tooling

⸻

Why We Use uv for Python

uv is used to manage Python dependencies because it:

* is fast and reproducible
* integrates well with existing Python workflows
* operates cleanly within the mamba-provided Python runtime

⸻

Why We Do NOT Use Conda for R/Python Packages

Although mamba can install R and Python packages, we intentionally avoid using it for project-level dependencies.

Reasons:

* conda packages may lag behind CRAN/PyPI
* mixing conda and language-native package managers causes conflicts
* lockfile-based reproducibility is better handled by renv and uv

⸻

Design Principles

This setup follows a few core principles:

1. Separation of concerns
    * system libraries vs project dependencies
2. Single source of truth per layer
    * no overlapping package managers
3. Reproducibility over convenience
    * explicit configuration instead of implicit environments
4. HPC compatibility
    * avoid assumptions about system-level control

⸻

Summary

Layer	Tool	Responsibility
HPC / OS	Cluster	glibc, kernel, scheduler
Runtime	mamba	R, Python, GDAL, GEOS, PROJ
R packages	renv	R dependency management
Python packages	uv	Python dependency management

This architecture ensures that the land-use data pipeline is:

* reproducible
* portable
* maintainable
* robust to HPC constraints
