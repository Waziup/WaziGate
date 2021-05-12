WaziGate developpers documentation
=================================

This folder contains implementation details about the WaziGate software for developpers.
User documentation can be found in the [Waziup website](www.waziup.io).

The WaziGate is realized in containerized components written mainly in Go language.
The containers are running in a Docker platform directly on the Raspberry PI.
All the components and kept in separate GitHub repositories.
The various components are integrated together in the main GitHub repository (this repository), using git “submodules” feature.

The following topics are covered:
- [ISO image creation](GenerateISO.md)
- [Raspberry PI system management](System.md)
- [LoRaWAN management](LoRaWAN.md)
- [WaziGate apps](Apps.md)
