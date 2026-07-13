# Unifying transcranial focused ultrasound and transcranial magnetic stimulation effects with calcium-dependent synaptic plasticity theory

This repository includes the code required to reproduce the results in:
**"Unifying transcranial focused ultrasound and transcranial magnetic stimulation effects with calcium-dependent synaptic plasticity theory"**

## Publication information:
**BioRxiv**
DOI:

## Authors:
- Yupeng Tian<sup>1,2,3</sup>
- Kevin Kadak<sup>3,4</sup>
- Khushi Kankaria<sup>5</sup>
- Ravindu Upasena<sup>6</sup>
- Kumar Murty<sup>1,7</sup>
- Robert Chen<sup>8,9,10</sup>
- John Griffiths<sup>3,4,11,12</sup>

## Affiliations:
1. Department of Mathematics, University of Toronto
2. The Fields Institute for Research in Mathematical Sciences, Toronto
3. Krembil Centre for Neuroinformatics, Centre for Addiction and Mental Health, Toronto
4. Institute of Medical Science (IMS), University of Toronto
5. Department of Physiology, University of Toronto
6. Institute of Biomedical Engineering, University of New Brunswick
7. Lodha Mathematical Sciences Institute, Mumbai
8. Krembil Research Institute, University Health Network, Toronto
9. Division of Neurology, Department of Medicine, University of Toronto
10. Edmond J. Safra Program in Parkinson’s Disease, University Health Network, Toronto
11. Department of Psychiatry, University of Toronto
12. Institute of Biomedical Engineering, University of Toronto

## TMS or TFUS is delivered to human brain model through an equivalent-energy principle (Fig. 1)
The TMS waveform consists of bursts of discrete pulses. The burst/pulse in a TFUS waveform is continuous, and it impacts the brain through an interface. We hypothesize that this interface filters the MHz activity (in the original sonication waveform) to a sinusoidal pulse with oscillation frequency below 1 kHz, which is in the frequency range that the human brain could transmit. The parameters of TMS and TFUS bursts are linked through our equivalent-energy principle, which states the parameter relationship so that the energy delivered by the TMS and TFUS bursts are the same, provided the same carrier frequency (the reciprocal of inter-burst-interval). TMS or TFUS waveform is delivered to human brains; the illustration of the TFUS hardware and human brain is adjusted from Meng, Hynynen and Lipsman (2020). The impact of these two non-invasive neuromodulations is characterized by a neural field model with calcium-dependent plasticity mechanisms, using the same model parameters; thus, TFUS or TMS is exerted on the consistent neural system. The neural field model consists of cortex (including excitatory and inhibitory neurons), thalamus (including relay and reticular nuclei), and the synaptic connections. The plasticity effect is characterized by the change in the synaptic connection strength, which is modulated by intracellular calcium concentration.

<p align="center">
  <img src="https://github.com/user-attachments/assets/ceefbe77-7b1a-4469-95df-0597a7baf05f" width="900"/>
</p>

## Model captures empirical data of TMS- and TFUS-induced plasticity (Fig. 2)

The model reproduces empirical TFUS- and TMS-induced plasticity effects. Model predictions are compared with empirical data from TMS and TFUS studies, as well as with the neural-field model of Fung and Robinson (2014). **a)** Schematic of the modeling framework and comparison of model-predicted and empirical plasticity for cTB-TMS and cTB-TFUS protocols. TMS and TFUS waveforms are applied to the corticothalamic neural-field model, and stimulation-induced plasticity is quantified by the change in the cortical excitatory synaptic strength (*ν*<sub>ee</sub>). **b-c)** Model predictions are compared with empirical MEP changes for cTB-TMS and cTB-TFUS protocols with stimulation durations of 40 s and 80 s. TMS data are from Gamboa et al. (2010) (10 min post-stimulation), and TFUS data are from Zeng et al. (2024) (5 min post-stimulation). LTP, long-term potentiation; LTD, long-term depression. **d)** Comparison under additional TMS protocols besides cTB-TMS-40s, including iTB-TMS-200s, rTMS-1Hz, and rTMS-20Hz. Stimulation durations were adjusted so that all protocols delivered the same number of pulses. Model predictions are compared with empirical results from Gamboa et al. (2010), Chung et al. (2017), Wassermann et al. (1998), and Boggio et al. (2010), respectively. **e)** Comparison under additional TFUS protocols with inter-burst frequencies of 2, 5, and 10 Hz (Zeng et al. (2024)). Duty cycle (10 %) and sonication duration (80 s) were held constant. The 20 Hz result is a model prediction, as no corresponding experimental data are available.

<p align="center">
  <img src="https://github.com/user-attachments/assets/6572ddcd-e5fb-48c0-b5ec-d3f9baa11c81" width="900"/>
</p>

## Neural field model with calcium-dependent plasticity interpret TFUS and TMS mechanisms (Fig. 3)
**a)** We hypothesize that sonication and electromagnetic waveforms affect the neural network through a brain interface (Fig. 1), with the primary effect exerted on cortical excitatory neurons. The neural field model consists of four neural populations: cortical excitatory (*e*), cortical inhibitory (*i*), thalamic relay (*s*), and thalamic reticular (*r*). The parameter *ν*<sub>ab</sub> represents the synaptic connectivity strength projecting from population *b* to population *a*, with the connectivity profile adopted from Kadak et al. (2025). **b)** The neural field model incorporates calcium-dependent plasticity mechanisms, described by the corresponding equations and parameters for each synaptic connection (Kadak et al., 2025). Intracellular calcium concentration is modulated by metaplasticity mechanisms governing calcium conductance through N-methyl-D-aspartate (NMDA) receptors. **c)** The Ω function, supported by empirical data, characterizes how intracellular calcium concentration ([Ca<sup>2+</sup>]) influences synaptic connectivity strength. The parameters θ<sub>d</sub> and θ<sub>p</sub> denote the depression and potentiation thresholds, respectively, defining the ranges of long-term depression (LTD) and long-term potentiation (LTP) induced by [Ca<sup>2+</sup>]. **d)** At the molecular level, Ca<sup>2+</sup> influx occurs primarily through NMDA receptors and is modulated by extracellular Mg<sup>2+</sup>. Intracellular [Ca<sup>2+</sup>] plays a key role in shaping plasticity by regulating the conductance of α-amino-3-hydroxy-5-methyl-4-isoxazolepropionic acid (AMPA) receptors, which are associated with Na<sup>+</sup> influx. **e)** The model is simulated under four experimentally validated protocols (see Fig. 2): cTB-TFUS-40s, cTB-TFUS-80s, cTB-TMS-40s, and cTB-TMS-80s. The calcium-dependent plasticity mechanisms explain the resulting plasticity effects, reflected as changes in cortical excitability. This is quantified by post-stimulation increases in the excitatory-to-excitatory connectivity strength (*ν*<sub>ee</sub>). During stimulation, the dark green curve represents the moving average of [Ca<sup>2+</sup>] with a 1 s window, with the corresponding mean value indicated in the lower-right corner.

<p align="center">
  <img src="https://github.com/user-attachments/assets/53a89d1d-f5a7-40a7-83f5-42a412753efc" width="900"/>
</p>

## Model predicts plasticity effects in response to different TFUS parameters (Fig. 4)
We simulate the model in response to varying TFUS parameters, including amplitude (phenomenological), sonication duration, pulse repetition frequency (PRF), and duty cycle. The TFUS-induced plasticity effect is quantified as the change in cortical excitability measured by motor-evoked potentials (MEPs), computed as the ratio relative to the pre-TFUS baseline. Unless otherwise specified, default values are: sonication duration = 80 s, PRF = 5 Hz, and duty cycle = 10%. The default TFUS amplitude is indicated in panel <b>a</b> as the horizontal-axis value corresponding to the red star. **a.** TFUS-induced plasticity as a function of phenomenological amplitude. The amplitude is termed phenomenological because it arises from our hypothesized brain interface mapping from the original sonication waveform (Fig. 1). The red star marks the plasticity effect at the TFUS amplitude (*= 10.72*) corresponding to default stimulation settings, based on the equivalent-energy principle (Eq. 1). The purple star indicates the empirical plasticity effect reported by Zeng et al. (2024) under default TFUS conditions (Fig. 4), where sonication duration = 80 s, PRF = 5 Hz, and duty cycle = 10%. **b.** TFUS-induced plasticity as a function of sonication duration. **c.** TFUS-induced plasticity as a function of PRF. **d.** TFUS-induced plasticity as a function of duty cycle. The slope is not significantly different from zero (two-sided t-test, *p* = 0.30 > 0.05), indicating that plasticity is not affected by duty cycle when sonication duration is fixed. **e.** TFUS-induced plasticity as a function of duty cycle with controlled total TFUS-ON time. For each duty cycle, the sonication duration is adjusted so that total TFUS-ON time remains constant. The slope is significantly different from zero (two-sided t-test, *p* = 1.9 × 10⁻⁴ < 0.001), indicating that plasticity decreases as duty cycle increases under equal total TFUS-ON time.

<p align="center">
  <img src="https://github.com/user-attachments/assets/aeb07862-b2ae-40d7-b125-3c54f17efc89" width="900"/>
</p>

## Codes:
| File | Description |
|----------| -------------|
| main_FUS.m | the MATLAB driver code that generates the results from simulating different TFUS configurations |
| main_TMS.m | the MATLAB driver code that generates the results from simulating different TMS configurations |
| supporting_codes | folder of the MATLAB codes needed to run simulations, including model equations, omega functions for CaDP, etc. |
| py_codes | folder of the python codes that generate results (also included in the folder) consistent with MATLAB codes |
| plot_omega_function | folder of the MATLAB codes for plotting the omega function of calcium-dependent plasticity (CaDP) |
| codes_generating_figures | figure data can be generated by simply running the functions with provided inputs |
| readme | specific instructions for main_FUS.m and main_TMS.m |


## References:
- Y. Meng, K. Hynynen, and N. Lipsman, “Applications of focused ultrasound in the brain: from thermoablation to drug delivery,” Nat Rev Neurol, vol. 17, no. 1, pp. 7–22, Jan. 2021, doi: 10.1038/s41582-020-00418-z
- P. K. Fung and P. A. Robinson, “Neural field theory of synaptic metaplasticity with applications to theta burst stimulation,” J Theor Biol, vol. 340, pp. 164–176, Jan. 2014, doi: 10.1016/j.jtbi.2013.09.021
- O. L. Gamboa, A. Antal, V. Moliadze, and W. Paulus, “Simply longer is not better: reversal of theta burst after-effect with prolonged stimulation,” Exp Brain Res, vol. 204, no. 2, pp. 181–187, Jul. 2010, doi: 10.1007/s00221-010-2293-4
- K. Zeng et al., “Effects of different sonication parameters of theta burst transcranial ultrasound stimulation on human motor cortex,” Brain Stimul, vol. 17, no. 2, pp. 258–268, 2024, doi: 10.1016/j.brs.2024.03.001
- K. Kadak et al., “Alpha rhythm subharmonics underlie responsiveness to theta burst stimulation via calcium metaplasticity,” eLife, vol. 14, Nov. 2025, doi: 10.7554/eLife.108563.1







