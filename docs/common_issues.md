# Something doesn't work
Didn't find your answer here? Visit the [Discord server](https://discord.gg/2ZezMw2xvR) for support.

## Latest version
Make sure you have the latest version of all required resources.

**Downloads**  
• [Latest version of ac_radio](https://github.com/antond15/ac_radio/releases/latest)  
• [Latest version of pma-voice](https://github.com/AvarianKnight/pma-voice/releases/latest)

## Start order
ac_radio must be started **AFTER** pma-voice and/or any supported framework.

**Recommended order**
```cfg
ensure pma-voice
## Remove the commented lines if you're not using any of them.
# ensure es_extended / qb-core / ox_core
# ensure ox_inventory
ensure ac_radio
```
