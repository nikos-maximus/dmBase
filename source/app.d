//import std.stdio;
import bindbc.sdl;

immutable uint R_MASK = 0xFF000000;
immutable uint G_MASK = 0x00FF0000;
immutable uint B_MASK = 0x0000FF00;
immutable uint A_MASK = 0x000000FF;

uint CreateColor(in ubyte r, in ubyte g, in ubyte b, in ubyte a)
{
	return (r << 24) | (g << 16) | (b << 8) | (a);
}

void main()
{
	/*
	 This version attempts to load the SDL shared library using well-known variations of the library name for the host
	 system.
	*/
	SDLSupport ret = loadSDL();
	if (ret !=sdlSupport)
	{
		/*
		 Handle error. For most use cases, it's reasonable to use the the error handling API in bindbc-loader to retrieve
		 error messages for logging and then abort. If necessary, it's possible to determine the root cause via the return
		 value:
		*/

		if (ret == SDLSupport.noLibrary)
		{
			// The SDL shared library failed to load
		}
		else if (SDLSupport.badLibrary)
		{
			/*
			 One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_204, GLFW_2010 etc.)
			*/
		}
	}
	
	/*
	 This version attempts to load the SDL library using a user-supplied file name. Usually, the name and/or path used
	 will be platform specific, as in this example which attempts to load `sdl2.dll` from the `libs` subdirectory,
	 relative to the executable, only on Windows.
	*/
	version(Windows) loadSDL("lib/sdl2.dll");

	if (SDL_Init(SDL_INIT_VIDEO) == 0)
	{
		immutable int WINDOW_WIDTH = 800;
		immutable int WINDOW_HEIGHT = 450;
		SDL_Window* window = SDL_CreateWindow("DM", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WINDOW_WIDTH, WINDOW_HEIGHT, 0);
		if (window)
		{
			SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
			if (renderer)
			{
				ubyte r = 255, g = 100, b = 10, a = 255;
				SDL_SetRenderDrawColor(renderer, r, g, b, a);
				bool running = true;

				SDL_Surface* windowDstSurface = SDL_CreateRGBSurface(0, WINDOW_WIDTH, WINDOW_HEIGHT, 32, R_MASK, G_MASK, B_MASK, A_MASK);
				uint* pixels = cast(uint*)(windowDstSurface.pixels);
				for (int row = 0;row < WINDOW_HEIGHT; ++row)
				{
					for (int col = 0; col < WINDOW_WIDTH; ++col)
					{
						pixels[row * WINDOW_WIDTH + col] = CreateColor(cast(ubyte)col, cast(ubyte)row, 0, 255);
					}
				}

				while(running)
				{
					SDL_PumpEvents();
					SDL_Event evt;
					while(SDL_PollEvent(&evt))
					{
						switch(evt.type)
						{
							case SDL_QUIT:
							{
								running = false;
								break;
							}
							default:
							{
								continue;
							}
						}
					}
					//SDL_RenderClear(renderer);
					SDL_BlitSurface(windowDstSurface, null, SDL_GetWindowSurface(window), null);
					SDL_UpdateWindowSurface(window);
					//SDL_RenderPresent(renderer);
				}
				SDL_DestroyRenderer(renderer);
			}
			SDL_DestroyWindow(window);
		}
		SDL_Quit();
	}
}
