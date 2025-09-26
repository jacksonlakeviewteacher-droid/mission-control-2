
# Shark_Gun Helper Scripts (drop these into your mod project root)
Target path: C:\Dev\Minecraft_Shark_Gun_Mod\

Files:
- 1_run_dev_client.bat
- 2_new_item.ps1
- 3_build_release.bat
- 4_fix_common_issues.bat

Notes:
- Update JAVA_HOME path below if your JDK 21 is different.
- The PowerShell script looks for marker comments in ModItems.java to safely insert new lines.
  Add these once if you don't have them yet:
    // AUTOGEN-IMPORTS-START
    // AUTOGEN-IMPORTS-END
    // AUTOGEN-REGISTRY-START
    // AUTOGEN-REGISTRY-END
    // AUTOGEN-REGISTER-START
    // AUTOGEN-REGISTER-END
