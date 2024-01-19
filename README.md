# TinyDTClient
A minimum client for Draw Things API

TinyDTClient is a tiny MacOS SwiftUI Application demonstrating the basic functions for a client to the awesome Image generation app, Draw Things (DT). It is extracted from the full-featured client, PromptWriter.

Dependancy: TinyDTClient depends on the library [RealHTTP](https://github.com/immobiliare/RealHTTP) for the low level http client stuff. Thanks to Immobillaire

The app attempts to connect to a DT server at its default address, and has no UI for configuring server info, so DT must be running on the same mac, with HTTP server on, at port 7860.
The app makes image requests on the API,  sending json with 3 parameters: 
{"prompt":"-your prompt-","negative_prompt":"", "seed":-1} 
\(prompt from the prompt field, blank negative prompt, random seed\)

All other image settings are done directly in DT.
There's no error handling or user feedback.

If you wanted to experiment with building a stable diffusion front end, you could add to the UI here - such as a text field for negative prompt, or controls for # of steps, etc.

<img width="1373" alt="Screenshot 2024-01-19 at 12 58 42 PM" src="https://github.com/S1D1T1/TinyDTClient/assets/156350598/dbd609e6-af97-4e3e-8f54-c3a002ec0c07">

TinyDTClient running alongside Draw Things
