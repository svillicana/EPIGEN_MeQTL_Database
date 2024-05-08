#### Columns

- **CpG**: CpG ID.
- **SNP**: meQTL SNP ID in the format of `chr:pos_A1_A2`.
- **LD clump**: LD block ID assigned to the top SNP after LD-based clumping (only available for the `Clumped meQTLs` dataset).
- **CpG chr** and **CpG pos**: chromosome and position of CpG.
- **SNP chr** and **SNP pos**: chromosome and position of top SNP.
- **A1**: reference allele according to the 1000 Genomes reference panel.
- **A2**: effect allele.
- **MAF**: minor allele frequency for the top SNP.
- **Beta** ($\beta$): association coefficient estimate, with respect to A2.
- **SE**: standard error of $\beta$ coefficient.
- **P**: nominal *P*-value of the $\beta$ coefficient.
- **FDR**: *P*-value after multiple testing adjustment with the permutation approach.
- **N**: number of sample sets with the candidate association used in the meta-analysis.
- **n**: number of samples used in the meta-analysis.
- **Effects**: direction of the effects in the sample sets TwinsUK, 1946BC-99, 1946BC-09, 1958BC-1 and 1958BC-2, respectively. `+` indicates a positive effect, `-` negative and `?` no effect in the sample set.
- ***Cis/Trans***: type of association, can be *cis* ($\leq$ 1 Mbp between top SNP and CpG) or *trans* (all others).
