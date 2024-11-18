#include <reg51.h>

// Pin definitions
sbit INC_BUTTON = P0^0;    // Button to increase reference by 10%
sbit DEC_BUTTON = P0^1;    // Button to decrease reference by 10%
sbit PWM_OUT = P2^0;       // PWM output pin

// Global variables
unsigned char sawtooth = 0;     // Sawtooth counter
unsigned char reference = 128;   // Reference voltage (starts at mid-range)
unsigned int on_time = 0;       // PWM on time counter
unsigned int off_time = 0;      // PWM off time counter
bit inc_pressed = 0;           // Button state flags
bit dec_pressed = 0;

// Simple delay function
void delay(unsigned int count) {
    while(count--);
}

// Function to handle 10% increment
void increase_reference(void) {
    unsigned int temp;
    temp = (unsigned int)reference + (reference / 10);  // Add 10%
    if(temp <= 255) {  // Check if within valid range
        reference = (unsigned char)temp;
    }
}

// Function to handle 10% decrement
void decrease_reference(void) {
    unsigned int temp;
    temp = (unsigned int)reference - (reference / 10);  // Subtract 10%
    if(temp > 0) {  // Check if within valid range
        reference = (unsigned char)temp;
    }
}

// Function to handle button inputs with debounce
void check_buttons(void) {
    // Handle increase button
    if(!INC_BUTTON && !inc_pressed) {  // Button pressed and was not pressed before
        delay(1000);  // Debounce
        if(!INC_BUTTON) {
            increase_reference();
            inc_pressed = 1;
        }
    }
    else if(INC_BUTTON && inc_pressed) {  // Button released
        inc_pressed = 0;
    }
    
    // Handle decrease button
    if(!DEC_BUTTON && !dec_pressed) {  // Button pressed and was not pressed before
        delay(1000);  // Debounce
        if(!DEC_BUTTON) {
            decrease_reference();
            dec_pressed = 1;
        }
    }
    else if(DEC_BUTTON && dec_pressed) {  // Button released
        dec_pressed = 0;
    }
}

void main(void) {
    // Initialize ports
    P1 = 0x00;    // Initial reference voltage output port
    P2 = 0x00;    // Initial PWM output port
    P3 = 0x00;    // Initial sawtooth output port
    
    while(1) {
        // Generate and output sawtooth waveform
        sawtooth++;           // Increment sawtooth counter (auto-rolls over at 255)
        P3 = sawtooth;        // Output sawtooth to P3 for oscilloscope
        
        // Output reference voltage
        P1 = reference;       // Output reference to P1 for oscilloscope
        
        // Compare sawtooth with reference to generate PWM
        if(sawtooth < reference) {
            PWM_OUT = 1;      // Set PWM high
            on_time++;        // Count on-time
            off_time = 0;     // Reset off-time counter
        } else {
            PWM_OUT = 0;      // Set PWM low
            off_time++;       // Count off-time
            on_time = 0;      // Reset on-time counter
        }
        
        // Check button inputs
        check_buttons();
        
        // Delay for controlling waveform frequency
        delay(50);           // Adjust this value to change frequency
    }
}
