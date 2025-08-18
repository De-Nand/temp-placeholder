#include <stdio.h>
#include <stdlib.h>
#include "SDL3/SDL.h"


static SDL_FRect rectangles[2];
static int DELTA_X, DELTA_Y;
static SDL_FRect overlap;

// Order of functions declared is important
// This has to be above as it is called later on
char isRectangleMoving(int mX, int mY) {
    printf("%d / %d\n", mX, mY);
    if (mX > rectangles[0].x && mX < (rectangles[0].x + rectangles[0].w) && mY > rectangles[0].y && mY < (rectangles[0].y + rectangles[0].h) ) {
        DELTA_X = rectangles[0].x - mX;
        DELTA_Y = rectangles[0].y - mY;
        return 10;
    }
    if (mX > rectangles[1].x && mX < (rectangles[1].x + rectangles[1].w) && mY > rectangles[1].y && mY < (rectangles[1].y + rectangles[1].h) ) {
        DELTA_X = rectangles[1].x - mX;
        DELTA_Y = rectangles[1].y - mY;
        return 11;
    }
    return 02;
}

bool isThereOverlap() {
    if (rectangles[0].x > rectangles[1].x) {
        if (rectangles[0].x < rectangles[1].x + rectangles[1].w) {
            overlap.w = rectangles[1].x + rectangles[1].w - rectangles[0].x;
            overlap.x = rectangles[0].x;
        } else {
            overlap.w = 0;
            overlap.x = 0;
        }
    } else if (rectangles[1].x > rectangles[0].x) {
        if (rectangles[1].x < rectangles[0].x + rectangles[0].w) {
            overlap.w = rectangles[0].x + rectangles[0].w - rectangles[1].x;
            overlap.x = rectangles[1].x;
        } else {
            overlap.w = 0;
            overlap.x = 0;
        }
    }

    if (rectangles[0].y > rectangles[1].y) {
        if (rectangles[0].y < rectangles[1].y + rectangles[1].h) {
            overlap.h = rectangles[1].y + rectangles[1].h - rectangles[0].y;
            overlap.y = rectangles[0].y;
        } else {
            overlap.h = 0;
            overlap.y = 0;
        }
    } else if (rectangles[1].y > rectangles[0].y) {
        if (rectangles[1].y < rectangles[0].x + rectangles[0].h) {
            overlap.h = rectangles[0].y + rectangles[0].h - rectangles[1].y;
            overlap.y = rectangles[1].y;
        } else {
            overlap.h = 0;
            overlap.y = 0;
        }
    }
    
    return overlap.w > 0 && overlap.h > 0;
}

int main() {
    printf("Hello, world\n");

    if (SDL_Init(SDL_INIT_VIDEO) == false ) {
        printf("SDL COULD not initalize the video");
        return 1;
    }
    
    SDL_Window *window = NULL; // A pointer to the SDL Window Struct
    window = SDL_CreateWindow("SDL3 C", 800, 600, 0 );
    if (window == false) {
        printf("Failed to start the window");
        return 2;
    }

    SDL_Renderer *renderer = NULL;
    renderer = SDL_CreateRenderer(window, NULL);
    if (renderer == false) {
        printf("Failed to start the renderer");
        return 3;
    }

    //Rectangles
    rectangles[0].x = 100;
    rectangles[0].y = 100;
    rectangles[0].w = 100;
    rectangles[0].h = 100;
    rectangles[1].x = 200;
    rectangles[1].y = 200;
    rectangles[1].w = 100;
    rectangles[1].h = 100;

    bool running = true;
    bool moving = false;
    bool overlapRect = false;
    int motion = 2;
    SDL_Event event;
    printf("Starting first while loop\n");

    while ( running == true ) {

        while ( SDL_PollEvent(&event) == true ) {
            switch(event.type) {
                case SDL_EVENT_QUIT:
                    printf("Quit event\n");
                    SDL_DestroyRenderer(renderer);
                    running = false;
                    break;
                case SDL_EVENT_MOUSE_BUTTON_DOWN:
                    printf("Mouse button down\n");
                    switch(isRectangleMoving((int)event.motion.x, (int)event.motion.y)) {
                        case 10:
                            motion = 0;
                            moving = true;
                            break;
                        case 11:
                            motion = 1;
                            moving = true;
                            break;
                    }
                    break;
                case SDL_EVENT_MOUSE_BUTTON_UP:
                    printf("Mouse button up\n");
                    moving = false;
                    break;
                case SDL_EVENT_MOUSE_MOTION:
                    if (moving == true) {
                        rectangles[motion].x = (int)event.motion.x + DELTA_X;
                        rectangles[motion].y = (int)event.motion.y + DELTA_Y;
                        overlapRect = isThereOverlap();
                    }
                    break;
            }

            //Render events - Order matters!
            // Background
            SDL_SetRenderDrawColor(renderer, 0,0,0,100);
            SDL_RenderClear(renderer);

            // Rectangles
            SDL_SetRenderDrawColor(renderer, 110, 115, 229, 90);
            SDL_RenderRect(renderer, &rectangles[0]);
            SDL_SetRenderDrawColor(renderer, 229, 72, 51, 90);
            SDL_RenderRect(renderer, &rectangles[1]);

            //Overlap
            if (overlapRect) {
                SDL_SetRenderDrawColor(renderer, 81, 255, 65, 100);
                SDL_RenderFillRect(renderer, &overlap);
            }

            SDL_RenderPresent(renderer);

        }

    }
    return 0;
}

