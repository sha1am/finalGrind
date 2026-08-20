```c++
// maximum subarray sum of size k 
int i=0;j=0;
int sum =0;
int mx = 
while(j<size){
  	sum+=nums[j];
  	if( j-i+1 <k){
      j++;
		}else if(j-i+1 == k ){
      mx = max(mx, sum);
      sum -=(nums[i]);
      i++; j++;
    }
}
return mx;
```





```c++
// first negative integer in every window of size k

  
```





**LangChain – 9 months, LangGraph – 3 months, LLMs – 8 months.** Worked on building LLM-powered applications, including RAG pipelines, agent workflows, tool calling, and prompt engineering.