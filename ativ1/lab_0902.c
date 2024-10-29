/*    
   Disclaimers
   ALL INFORMATION PROVIDED WITHIN OR OTHERWISE ASSOCIATED WITH THIS 
   PUBLICATION  INCLUDING, INTER ALIA, ALL SOFTWARE CODE, IS PROVIDED
   "AS IS”, AND FOR EDUCATIONAL PURPOSES ONLY. INTEL RETAINS ALL 
   OWNERSHIP INTEREST IN ANY INTELLECTUAL PROPERTY RIGHTS ASSOCIATED 
   WITH THIS INFORMATION AND NO LICENSE, EXPRESS OR IMPLIED, BY 
   ESTOPPEL OR OTHERWISE, TO ANY INTELLECTUAL PROPERTY RIGHT IS GRANTED
   BY THIS PUBLICATION OR AS A RESULT OF YOUR PURCHASE THEREOF. INTEL 
   ASSUMES NO LIABILITY WHATSOEVER AND INTEL DISCLAIMS ANY EXPRESS OR 
   IMPLIED WARRANTY RELATING TO THIS INFORMATION INCLUDING, BY WAY OF 
   EXAMPLE AND NOT LIMITATION, LIABILITY OR WARRANTIES RELATING TO 
   FITNESS FOR A PARTICULAR PURPOSE, MERCHANTABILITY, OR THE INFRINGEMENT
   OF ANY INTELLECTUAL PROPERTY RIGHT ANYWHERE IN THE WORLD.


   THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS’’ AND ANY EXPRESS OR 
   IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
   WARRANTIES    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
   ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
   INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
   IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
   POSSIBILITY OF SUCH DAMAGE.
*/

/*
   Lab 9.2: Multithreading the Pi Program.
   Must compile with -lpthreads switch.
*/

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define MAXTHREADS 8

// Use 200 million steps
long num_steps = 200000000;
double sum = 0.0;
int nThreads;

void *computePi(void *pArg)
{
    double step, x;
    int i;
    int myNum = *((int *)pArg);
	
	step = 1.0/(double) num_steps;

    for (i = myNum; i < num_steps; i+=nThreads) {
        x = (i+0.5)*step;
        sum += 4.0/(1.0 + x*x);
    }
    return NULL;
}

int main(int argc, char * argv[])
{
    int i;
    double x;
    double step, pi;
    int tNum[MAXTHREADS];
    pthread_t tid[MAXTHREADS];

    if (argc < 1) {
        printf("Usage: %s <number of threads>\n", argv[0]);
        return -1;
    }

    step = 1.0/(double) num_steps;
    nThreads = 8;

    if (argc == 2)
        nThreads = atoi(argv[1]);

    if (nThreads > MAXTHREADS)
        exit(0);

    printf("Num threads = %d\n", nThreads);
    for (i = 0; i < nThreads; i++) {
        tNum[i] = i;
        pthread_create(&tid[i], NULL, computePi, &tNum[i]);
    }

    for (i = 0; i < nThreads; i++) {;
        pthread_join(tid[i], NULL);
    }

    pi = step * sum;
    printf("Pi = %14.8f\n",pi);
    return 0;
}
