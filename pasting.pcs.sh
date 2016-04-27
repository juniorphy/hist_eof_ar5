paste `ls -1 */dtred/PC2.MAM.*.txt` > PC2.MAM.models.txt ; paste ../../sst-data/PC2.MAM.txt PC2.MAM.models.txt > PC2.MAM.obs.models.txt

paste `ls -1 */dtred/PC1.MAM.*.txt` > PC1.MAM.models.txt ; paste ../../sst-data/PC1.MAM.txt PC1.MAM.models.txt > PC1.MAM.obs.models.txt

paste `ls -1 */dtred/PC1.DJF.*.txt` > PC1.DJF.models.txt ; paste ../../sst-data/PC1.DJF.txt PC1.DJF.models.txt > PC1.DJF.obs.models.txt

paste `ls -1 */dtred/PC2.DJF.*.txt` > PC2.DJF.models.txt ; paste ../../sst-data/PC2.DJF.txt PC2.DJF.models.txt > PC2.DJF.obs.models.txt

rm -rfv PC2.MAM.models.txt PC1.DJF.models.txt PC1.MAM.models.txt PC2.DJF.models.txt 

