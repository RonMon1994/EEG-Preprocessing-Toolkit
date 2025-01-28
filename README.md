# EEG-Preprocessing-Toolkit

## Overview
This repository contains MATLAB scripts for a comprehensive EEG data preprocessing pipeline using EEGLAB. It is designed to facilitate the cleaning, artifact removal, and epoch extraction for EEG datasets, particularly for GO and NOGO experimental conditions.

## Features
- Channel rejection based on specific thresholds.
- Independent Component Analysis (ICA) for artifact identification.
- Customizable pipeline for different stages of EEG data cleaning and processing.
- Epoch processing for GO and NOGO conditions.
- Event-Related Potential (ERP) processing and output.

## Prerequisites
- MATLAB R2023b or later
- EEGLAB installed and set up on your machine

## Installation
1. Clone this repository to your local machine.
2. Ensure EEGLAB is in your MATLAB path as shown in the scripts.

## Usage
Follow the instructions in each script starting from the `main.m` to execute the preprocessing pipeline. Adjust paths and parameters according to your dataset configuration.

## Contributing
Contributions to this project are welcome! Please fork the repository and submit pull requests with your improvements.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements
This pipeline was developed by Ron Montaoriano as part of the Deep Brain Stimulation Project at [Your Institution or Lab].
