# Droplet flow in a bifurcated millifluidic loop

Millifluidics involves manipulation of fluids that are on the milli-scale. The real-world applications of millifluidics range from simplified versions of 
common place medical tests to groundbreaking research projects.

A bifurcated loop refers to a single fluid pipe that branches into two and is rejoined back later to form a loop (with two openings). Droplet flow of alternating colors through this setup are simulated 
using the proposed alogrithm [1]. The two channel are slightly asymmetrical and their dimensions are fixed in the simulation. 


https://user-images.githubusercontent.com/76219678/164986133-4626c67c-e7ef-467e-87c4-12b5f148f3c7.mp4

## The Algorithm
The authors have devised an algorithm to predict the behaviour of droplets in a bifurcated loop by estimating and quantifying channel resistances (resistance offered to flow of droplet in each channel).
The dynamics of the channel (flow rate, velocity, etc.) change whenever a droplet enters or exits a channnel. The flow is unidirectional in nature. The algorithm is as follows,


<ol>
  <li>
    <div>
      Compute the flow rates in each channel for a given set of droplet positions
      <img src="https://user-images.githubusercontent.com/76219678/164984066-517925c2-2542-485f-8b2c-091b6572e45e.png" alt = "Flow rate in longer channel">
      <img src="https://user-images.githubusercontent.com/76219678/164984432-9757bc07-538d-4d06-ae6c-508964a28baa.png" alt = "Flow rate in longer channel">
    </div>
  </li>
  
  <li>
    <div>
      <p>Determine the droplet velocities</p>
      <img src="https://user-images.githubusercontent.com/76219678/164984650-8524bf2b-d6fb-41f3-8df0-31d4d32eacc1.png" alt = "Flow rate in longer channel">
    </div>
  </li>
  
  <li>Determine the next time when a droplet arrives at a junction, i.e. either a  droplet entering a junction or exiting a junction, and advance all 
    droplets to this time</li>
  <li>Decide which route the triggering droplet takes, update the channel resistances of the affected channels, and return to the first step</li>
    
</ol>

## Abbreviations
![image](https://user-images.githubusercontent.com/76219678/164985435-ebb01afa-a17a-4b86-a02a-e9d011198a2c.png)


## References
[1] Schindler, Michael, and Armand Ajdari. "Droplet traffic in microfluidic networks: A simple model for understanding and designing." Physical Review Letters 100, no. 4 (2008): 044501

[2] Wang, W. S., & Vanapalli, S. A. (2014). Millifluidics as a simple tool to optimize droplet networks: Case study on drop traffic in a bifurcated loop. Biomicrofluidics, 8(6), 064111

[3] Labrot, Vincent, Michael Schindler, Pierre Guillot, Annie Colin, and Mathieu Joanicot. "Extracting the hydrodynamic resistance of droplets from their behavior in microchannel networks." Biomicrofluidics 3, no. 1 (2009): 012804

[4] Fuerstman, Michael J., Piotr Garstecki, and George M. Whitesides. "Coding/decoding and reversibility of droplet trains in microfluidic networks." Science 315, no. 5813 (2007): 828-832

## 
<b>NOTE:</b>Actual experimental results may deviate from the simulation results as environmental factors were not taken into account and some assumptions were made while calculating the required parameters.
