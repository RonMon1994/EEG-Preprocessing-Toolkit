# EEG-Preprocessing-Toolkit

## Overview
This repository is dedicated to a comprehensive suite of MATLAB scripts designed for the advanced preprocessing and analysis of EEG data using the EEGLAB software. It was developed through a collaborative effort with key contributions from Dr. Inbal Maidan and Dr. Zoya Katzir, leveraging their expertise to enhance the functionality and application scope of EEG analysis in both clinical and research settings.

The primary aim of this project is to provide researchers and clinicians with robust tools for cleaning, artifact removal, and epoch extraction specifically tailored for EEG datasets. By focusing on the needs associated with different experimental conditions, such as GO and NOGO tasks, the pipeline ensures that users can efficiently prepare data for detailed neuroscientific analysis and interpretation.

Key aspects of this collaboration involve integrating cutting-edge algorithms for signal processing with practical implementations that address common challenges in EEG data management. The scripts are structured to guide users from the initial stages of raw data handling to more complex procedures such as Independent Component Analysis (ICA) and Event-Related Potential (ERP) extraction. This approach not only facilitates a deeper understanding of the underlying neural mechanisms but also enhances the reliability and accuracy of the results obtained from EEG studies.

In partnering with Dr. Maidan and Dr. Katzir, the project taps into a wealth of knowledge and experience in neuroscience, ensuring that the tools developed are both scientifically rigorous and highly applicable in real-world scenarios. The collaboration aims to push the boundaries of what can be achieved with EEG data, driving forward innovations that could influence a wide range of applications from basic research to clinical diagnostics.

## Features
This repository provides a structured and comprehensive set of tools designed to optimize EEG data preprocessing and analysis workflows. Here is an overview of the key features associated with each script included in the repository:
- **main**: Serves as the entry point for the EEG preprocessing pipeline. This script orchestrates the execution of all preprocessing steps, ensuring that each component of the pipeline is executed in the correct sequence and with the appropriate parameters.
- **process_files**: A preprocessing utility that applies initial data cleaning routines to EEG files, preparing them for more detailed analysis such as ICA and ERP extraction.
- **remove_chans**: This script offers a method for removing noisy or unwanted channels from EEG datasets before further processing. Effective channel rejection is crucial for maintaining data quality and reliability.
- **perform_ica**: Applies Independent Component Analysis (ICA) to EEG datasets to identify and label artifacts and brain sources. This script is essential for the isolation of artifacts which can then be selectively removed to improve data quality.
- **flag_and_remove_artifacts**: This script automates the artifact removal process in EEG data sets. It identifies artifacts using predefined criteria and removes them effectively, ensuring cleaner data for subsequent analysis.
- **process_GO_epochs**: Focuses on processing epochs specifically tagged as 'GO' in behavioral tasks. It filters, corrects, and extracts epochs based on specific criteria, facilitating detailed analysis of responses in cognitive experiments.
- **process_NOGO_epochs**: Similar to the GO epochs processor, this script handles the 'NOGO' epochs. It ensures that non-response or control conditions in experiments are accurately processed and analyzed, maintaining the integrity of comparative studies.
- **processERPFiles**: This script processes event-related potentials (ERPs), calculating specific components relevant to the experimental conditions. It extracts, analyzes, and stores ERP features, providing insights into cognitive processes.
- **processEEGWithFOOOF2**: Implements advanced spectral analysis by fitting the power spectral density of EEG data to a model that separates periodic components from aperiodic noise. This method enhances the understanding of the underlying spectral components within the EEG recordings.

## Prerequisites
- MATLAB R2023b or later
- EEGLAB installed and set up on your machine

## Installation
1. Clone this repository to your local machine.
2. Ensure EEGLAB is in your MATLAB path as shown in the scripts.

## Usage
To use the pipeline:
1. Start with the main.m script and modify the paths and parameters to suit your dataset.
2. Sequentially run the scripts to perform the preprocessing and analysis stages.
3. Review the results generated in both MATLAB and Excel formats for comprehensive insights into the EEG data.

## Contributing
Contributions are highly appreciated. Please fork this repository, make your improvements, and submit a pull request. Your contributions can help enhance the functionality and utility of this pipeline.


## Acknowledgements
Special thanks to Dr. Zoya Katzir, a PhD researcher, for her significant contributions to the development and testing of these scripts. Her expertise in EEG analysis has been invaluable to this project. This work was also supported by Ichilov Hospital, which provided both data and research collaboration.
