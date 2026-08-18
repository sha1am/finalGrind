### Sliding Window ( Aditya V ) 

---

Notes:

Take a problem and try to solve it using Brute Force and then check how sliding window can be applied. ( complexity savings )

**Identification of sliding window problem.**:( Array or string ka question )+ ( Subarray, aur substring because window is continuos )  + ( largest or max or miin) + ( k ( window size) or cond ( variable size window ) ) 

Types of sliding window : Two types. ( fixed size window and variable sized window ( map use krna padd sakta hai))

Problems that we'lll solve: 

Fixed Size: 

1) Max/Min subarray of size k
2) 1st -ve in every window of size k 
3) Count occurance of anagrams
4) Max of all subarray of size k
5) Max of min for every window size.

Variable Sizes: 

1. Largest/smallest subarray of sum k
2. Largest substring of k distinct characters.
3. Length of largest substring with no repeating characters
4. Pick toy
5. Minimum Window substring

---

Problem1 : Max sum sub-array of size k

```c++
//my attempt: 
class Solution {
public:
    void insertMp(map<int,int>& mp, int num){
        if(mp.find(num)==mp.end()) mp[num]=1;
        else{
            mp[num]+=1;
        }
    }

    void eraseMp(map<int,int>& mp, int num){
        if(mp.find(num)==mp.end()){//element doesn't exist, cannot delete
        }
        else if(mp.find(num)!=mp.end()){
            if(mp[num]==1){ mp.erase(mp.find(num));}
            else mp[num]-=1;
        }
    }
    long long maximumSubarraySum(vector<int>& nums, int k) {
        int n= nums.size();
        int sP=0;int eP= sP+k-1;
        long long winSum=0;
        map<int,int> mP;
        for(int i=sP;i<=eP;i++){
            winSum+=nums[i];
            insertMp(mP, nums[i]);
        }

        long long mx=((mP.size()==k)? winSum: INT_MIN); //
        while(eP<n-1){
            eraseMp(mP,nums[sP]);winSum-=nums[sP++];
            winSum+=nums[++eP]; insertMp(mP,nums[eP]);
            if(mP.size()==k) mx=max(mx,winSum);
        }
        return ((mx!=INT_MIN)?mx:0);
    }
};
```

if i and j represent start and end of window then ( j-i+1) is the window size. 	

4th wali dekhnni hai. 

