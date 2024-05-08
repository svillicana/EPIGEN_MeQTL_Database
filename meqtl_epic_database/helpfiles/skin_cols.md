#### Columns

- **CpG**: CpG ID.
- **SNP**: meQTL SNP ID in the format of `chr:pos:SNP`.
- **CpG chr** and **CpG pos**: chromosome and position of CpG.
- **SNP chr** and **SNP pos**: chromosome and position of top SNP.
- **Effect Allele**: allele to which the $\beta$ estimate refers, which corresponds to the minor allele for the SNP.
- **Other Allele**: non-effect allele, which corresponds to the major allele for the SNP.
- **MAF**: minor allele frequency for the SNP.
- **Beta** ($\beta$): association coefficient estimate, with respect to the effect allele.
- **SE**: standard error of $\beta$ coefficient.
- **P**: nominal *P*-value of the $\beta$ coefficient.
- **FDR**: *P*-value after multiple testing adjustment with the permutation approach.
- ***Cis/Trans***: type of association, can be *cis* ($\leq$ 1 Mbp between top SNP and CpG) or *trans* (all others).

