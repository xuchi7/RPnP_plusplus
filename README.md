# A Hough Voting based 2-Point RANSAC Solution to the Perspective-n-Point Problem

<p align="center">
Chi Xu, Tingrui Guo, Yuan Huang, Li Cheng
</p>

## Abstract

Perspective-n-point is a fundamental problem in multi-view geometry, yet two critical challenges persist: (1) The issues of high outlier rate and near degenerate cases exert a substantial impact on the robustness of existing PnP methods. In the worst-case where both issues are in presence, existing methods tend to either produce erroneous results or become computationally prohibitive. (2) Conventionally, the hypothetical pose with the maximum inlier-set is assumed to be correct. However, it remains unclear whether this assumption holds when the outlier rate approaches ultra-high levels, and along this line what is the maximum amount of outliers that can be robustly handled. To address these challenges, this paper proposes a novel Hough voting based 2-point RANSAC solution. To our knowledge, it is the first PnP solution capable of accurately and efficiently handling high outlier rates in near-degenerate cases. Extensive empirical evaluations have been conducted using the proposed approach, with a particular focus on a systematic examination under ultra-high outlier rates. The results show that, on random synthetic data, our approach works robustly even when dealing with up to 99% outliers. Meanwhile on real-world datasets, the maximum inlier-set assumption oftentimes fails when the outlier rate exceeds 97%, as the incorrect hypothetical poses may yield more inliers than the ground-truths. Our dataset and source code are to be made available at [https://github.com/xuchi7/RPnP_plusplus].

## Datasets

Please download the files via the links below, then unzip the file to the root directory of this repository.

- Synthetic data [SynthData.zip](https://www.dropbox.com/scl/fi/tdhoqg0clbk5x0dufnywd/SynthData.zip?rlkey=jluqkkhvm2ekq6ytkoy85cdwk&st=m3y88alk&dl=0)

- Real data [RealData.zip](https://www.dropbox.com/scl/fi/s56b961lmlbcoxjbj36su/RealData.zip?rlkey=jhcn823ucfsch4louow57hjcl&st=kxozmgyu&dl=0)

- Star-River Complex [StarRiver.zip](https://www.dropbox.com/scl/fi/s4lvgzexaznsbt0f5lc03/StarRiver.zip?rlkey=wds3l24kp5m0nbgjg1txk0bow&st=gun22orb&dl=0)

## Source Code

This repository contains the implementation of the proposed **R2PPnP method based on Hough Voting**, along with its **refinement module**, and the full experimental pipeline for **Synthetic**, **Real**, and **StarRiver dataset** experiments.

The project includes:

* Source code (`src`)
  * Common functions (`common_funcs`)
* Experimental scripts for Synthetic, Real, and StarRiver data
* All required datasets under the `data/` directory (default test data and results included)

---

## Directory Structure

```
src/                               — Source code
    common_funcs/                  — Shared functions
        r2ppnp.m                   — Proposed Hough Voting–based method
        applyFinalize.m            — Proposed refinement method
	...
   
    # files for Synth Data Experiments
    main_syn_run.m                 — Main script to run synthetic data experiments
    main_syn_show_results.m        — Display synthetic experiment results
    generate_syn_data.m            — Synthetic data generation script
   
    # files for Real Data Experiments
    main_real_run.m                — Main script to run real data experiments
    main_real_show_results.m       — Display real experiment results
    main_real_show_images.m        — Display real image samples

    # files for StarRiver Experiments
    main_starriver_show_results.m  — Show StarRiver experiment results
    main_starriver_show_images.m   — Show StarRiver image samples

data/
    RealData/
        testData/                  — Real data experiment inputs
        testResults/               — Real data experiment outputs
    SynthData/   
        testData/                  — Synthetic data experiment inputs
        testResults/               — Synthetic data experiment outputs
    StarRiver/   
        splg/   
            testData/              — StarRiver synthetic-like test data
            testResults/           — StarRiver experiment results
        images_upright/            — StarRiver upright images
    RealImages/
        brandenburg_gate/
        buckingham_palace/
        ... (totally 10 scenes, each containing corresponding images)
```

---

## Running the Experiments

### 1. Synthetic Data Experiment

#### Run the experiment

```
main_syn_run.m
```

* Uses data from `data/SynthData/testData/`
* **By default, results are NOT overwritten**

To enable overwriting results:

* In `common_funcs/evaluate_syn.m` change line ~73:

  ```
  if 1 → if 0
  ```
* In `common_funcs/evaluate_syn_refinement.m` change line ~76:

  ```
  if 1 → if 0
  ```

#### Display results

```
main_syn_show_results.m
```

* Results are loaded from `data/SynthData/testResults/`

#### Generate new synthetic data (optional)

```
generate_syn_data.m
```

* Default data already exists in `data/SynthData/testData/`
* To regenerate new, change line 4:

  ```
  if 1 → if 0
  ```

---

### 2. Real Data Experiment

#### Run the experiment

```
main_real_run.m
```

* Uses data from `data/RealData/testData/`
* **By default, results are NOT overwritten**

To enable overwriting results:

* In `common_funcs/evaluate_real.m` change line ~36:

  ```
  if 1 → if 0
  ```
* In `common_funcs/evaluate_real_refinement.m` change line ~44:

  ```
  if 1 → if 0
  ```

#### Display results

```
main_real_show_results.m
```

* Experiments use `data/RealData/testData/`
* Results are loaded from `data/RealData/testResults/`

#### Display real images

```
main_real_show_images.m
```

* Images are located in `data/RealImages/`

---

### 3. StarRiver Experiment

#### Display StarRiver results

```
main_starriver_show_results.m
```

* Inputs: `data/StarRiver/splg/testData`
* Results: `data/StarRiver/splg/testResults`

#### Display StarRiver images

```
main_starriver_show_images.m
```

* Uses images from: `data/StarRiver/images_upright`

---

## Important Notes

### Handling Crashes in 3rd-party Code

Some third-party code may crash and interrupt the experiment.
To prevent this, **restore the commented `try–catch` blocks** in:

* `common_funcs/evaluate_real.m`
* `common_funcs/evaluate_real_refinement.m`
* `common_funcs/evaluate_syn.m`
* `common_funcs/evaluate_syn_refinement.m`

Example change:

**Original (commented out):**

```matlab
% try
    [R1, t1, ntrial] = func(X, x, K, th_pixel, varargin{:});
% catch
%     R1 = []; t1 = []; ntrial = 0;
% end
```

**Replace with:**

```matlab
try
    [R1, t1, ntrial] = func(X, x, K, th_pixel, varargin{:});
catch
    R1 = []; t1 = []; ntrial = 0;
end
```

This ensures experiments continue even if one method fails.

---
