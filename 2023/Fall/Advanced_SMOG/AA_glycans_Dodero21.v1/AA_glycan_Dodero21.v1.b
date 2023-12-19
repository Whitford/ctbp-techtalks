<?xml version="1.0"?>
<b>
  <!-- BONDS -->
  <bonds>
    <bond func="bond_harmonic(?,10000)">
      <bType>B_1</bType>
      <bType>B_1</bType>
    </bond>
    <!-- ESTEBAN -->
    <bond func="bond_harmonic(?,10000)">
      <bType>B_1</bType>
      <bType>B_2</bType>
    </bond>
    <bond func="bond_bytype()">
      <bType>B_2</bType>
      <bType>B_2</bType>
    </bond>
  </bonds>
  <!-- ANGLES -->
  <angles>
    <angle func="angle_harmonic(?,80)">
      <bType>B_1</bType>
      <bType>B_1</bType>
      <bType>B_1</bType>
    </angle>
    <!-- ESTEBAN -->
    <angle func="angle_harmonic(?,80)">
      <bType>B_2</bType>
      <bType>B_2</bType>
      <bType>B_1</bType>
      <!-- ESTEBAN -->
    </angle>
    <angle func="angle_harmonic(?,80)">
      <bType>B_2</bType>
      <bType>B_1</bType>
      <bType>B_1</bType>
    </angle>
    <angle func="angle_bytype()">
      <bType>B_2</bType>
      <bType>B_2</bType>
      <bType>B_2</bType>
    </angle>
  </angles>
  <!-- DIHEDRALS -->
  <dihedrals>
    <!-- NUCLEIC DIHEDRALS -->
    <dihedral func="dihedral_cosine(?,0.9175916584,1)+dihedral_cosine(?,0.4587958292,3)" energyGroup="bb_n">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_cosine(?,0.9175916584,1)+dihedral_cosine(?,0.4587958292,3)" energyGroup="sc_n">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_cosine4(0,40,2)" energyGroup="pr_n">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <!-- AMINO DIHEDRALS -->
    <dihedral func="dihedral_cosine(?,0.9175916584,1)+dihedral_cosine(?,0.4587958292,3)" energyGroup="bb_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_cosine(?,0.9175916584,1)+dihedral_cosine(?,0.4587958292,3)" energyGroup="sc_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_cosine4(0,40,2)" energyGroup="pr_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_cosine4(0,10,2)" energyGroup="r_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_harmonic(?,10)" energyGroup="pro_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <!-- LIGAND DIHEDRALS -->
    <dihedral func="dihedral_cosine(?,0.9175916584,1)+dihedral_cosine(?,0.4587958292,3)" energyGroup="bb_l">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_cosine4(0,40,2)" energyGroup="r_l">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <!-- GLYCAN DIHEDRALS HARMONIC -->
    <dihedral func="dihedral_harmonic(?,40)" energyGroup="bb_g">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <!-- GLYCAN DIHEDRALS -->
    <dihedral func="dihedral_free()" energyGroup="free_g">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
  </dihedrals>
  <!-- IMPROPERS -->
  <impropers>
    <improper func="dihedral_harmonic(?,10)">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </improper>
  </impropers>
</b>
