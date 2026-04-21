# Unifying transcranial focused ultrasound and transcranial magnetic stimulation effects with calcium-dependent synaptic plasticity theory

This repository includes the code required to reproduce the results in:
**"Unifying transcranial focused ultrasound and transcranial magnetic stimulation effects with calcium-dependent synaptic plasticity theory"**

## Publication information:
**BioRxiv**
DOI:

## Authors:
- Yupeng Tian<sup>1,2,3</sup>
- Kevin Kadak<sup>3,4</sup>
- Kumar Murty<sup>1,5</sup>
- Robert Chen<sup>6,7,8</sup>
- John Griffiths<sup>3,4,9,10</sup>

## Affiliations:
1. Department of Mathematics, University of Toronto
2. The Fields Institute for Research in Mathematical Sciences, Toronto
3. Krembil Centre for Neuroinformatics, Centre for Addiction and Mental Health, Toronto
4. Institute of Medical Science (IMS), University of Toronto
5. Lodha Mathematical Sciences Institute, Mumbai
6. Krembil Research Institute, University Health Network, Toronto
7. Division of Neurology, Department of Medicine, University of Toronto
8. Edmond J. Safra Program in Parkinson’s Disease, University Health Network, Toronto
9. Department of Psychiatry, University of Toronto
10. Institute of Biomedical Engineering, University of Toronto

## TMS or TFUS is delivered to human brain model through an equivalent-energy principle
The TMS waveform consists of bursts of discrete pulses. The burst/pulse in a TFUS waveform is continuous, and it impacts the brain through an interface. We hypothesize that this interface filters the \(MHz\) activity (in the original sonication waveform) to a sinusoidal pulse with oscillation frequency below \(1 kHz\), which is in the frequency range that the human brain could transmit. The parameters of TMS and TFUS bursts are linked through our equivalent-energy principle, which states the parameter relationship so that the energy delivered by the TMS and TFUS bursts are the same, provided the same carrier frequency (the reciprocal of inter-burst-interval). TMS or TFUS waveform is delivered to human brains; the illustration of the TFUS hardware and human brain is adjusted from Meng, Hynynen and Lipsman (2020). The impact of these two non-invasive neuromodulations is characterized by a neural field model with calcium-dependent plasticity mechanisms, using the same model parameters; thus, TFUS or TMS is exerted on the consistent neural system. The neural field model consists of cortex (including excitatory and inhibitory neurons), thalamus (including relay and reticular nuclei), and the synaptic connections. The plasticity effect is characterized by the change in the synaptic connection strength, which is modulated by intracellular calcium concentration.

<p align="center">
  <img src="https://github.com/user-attachments/assets/ceefbe77-7b1a-4469-95df-0597a7baf05f" width="900"/>
</p>

## Model captures empirical data of TMS- and TFUS-induced plasticity
We validate our model-predicted plasticity effects by comparing with empirical data from both TMS and TFUS, and a previously established TMS modeling work Fung \& Robinson (2014). **a.** The TMS or TFUS waveform is delivered to the neural field model consisting of cortical and thalamic nuclei. *ν*<sub>ab</sub> represents the synaptic connection strength from neural group \(b\) to group \(a\). The model-predicted plasticity effect is the change in *ν*<sub>ee</sub>, an indicator of cortical excitability. In empirical data, the plasticity or cortical excitability is represented by the ratio of change in motor-evoked potential (MEP) to its pre-stimulation baseline value. cTB-TMS is a typical TMS protocol with burst of pulses continuously delivered at 5Hz of inter-burst frequency (Gamboa et al. (2010)), and cTB-TFUS similarly means that the inter-burst frequency is 5Hz, 10% of duty cycle is used as in Zeng et al. (2024). cTB-TMS (resp., cTB-TFUS) was delivered with a total stimulation time with either 40s or 80s. cTB-TMS data are from Gamboa et al. (2010) (recorded 10-min post-stimulation), and cTB-TFUS data are from Zeng et al. (2024) (recorded 5-min post-stimulation). LTP: long-term potentiation. LTD: long-term depression. **b.** Comparisons in response to more TMS protocols, including iTB-TMS-200s, rTMS-1Hz and rTMS-10Hz, besides cTB-TMS-40s. iTB-TMS means intermittent theta-burst stimulation (2s of cTB-TMS followed by 8s of TMS-OFF). rTMS means repetitive TMS with one pulse per burst (inter-burst frequency = 1Hz or 10Hz). The stimulation time of these four TMS protocols is controlled so that the same number of pulses (i.e., same energy) is delivered to the model. TMS protocols are evaluated at 20-min post-stimulation to show the long-term plasticity effects. Based on empirical data, cTB-TMS-40s induces LTD (Gamboa et al. (2010)), iTB-TMS-200s induces LTP (Chung et al. (2017)), rTMS-1Hz induces LTD (Wassermann et al. (1998)) and rTMS-10Hz induces LTP (Di Lazzaro et al. (2010)). **c.** Comparisons in response to more TFUS protocols from Zeng et al. (2024). We compared results in response to different inter-burst-frequency (2Hz, 5Hz (theta-burst), and 10Hz), with the same duty cycle at 10% and the total stimulation time at 80s. We simulated the result for 20Hz-TFUS (not recorded in Zeng et al. (2024)) to show that our model can predict the LTP decrease as the inter-burst-frequency increases beyond 5Hz.

<p align="center">
  <img src="https://github.com/user-attachments/assets/aa042436-5274-4da8-acdb-783bc95b0cb8" width="900"/>
</p>











