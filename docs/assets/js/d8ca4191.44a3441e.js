"use strict";(self.webpackChunkdocs_openc3_com=self.webpackChunkdocs_openc3_com||[]).push([[8977],{3905:(e,t,i)=>{i.d(t,{Zo:()=>d,kt:()=>b});var n=i(7294);function r(e,t,i){return t in e?Object.defineProperty(e,t,{value:i,enumerable:!0,configurable:!0,writable:!0}):e[t]=i,e}function a(e,t){var i=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),i.push.apply(i,n)}return i}function o(e){for(var t=1;t<arguments.length;t++){var i=null!=arguments[t]?arguments[t]:{};t%2?a(Object(i),!0).forEach((function(t){r(e,t,i[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(i)):a(Object(i)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(i,t))}))}return e}function s(e,t){if(null==e)return{};var i,n,r=function(e,t){if(null==e)return{};var i,n,r={},a=Object.keys(e);for(n=0;n<a.length;n++)i=a[n],t.indexOf(i)>=0||(r[i]=e[i]);return r}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(n=0;n<a.length;n++)i=a[n],t.indexOf(i)>=0||Object.prototype.propertyIsEnumerable.call(e,i)&&(r[i]=e[i])}return r}var l=n.createContext({}),c=function(e){var t=n.useContext(l),i=t;return e&&(i="function"==typeof e?e(t):o(o({},t),e)),i},d=function(e){var t=c(e.components);return n.createElement(l.Provider,{value:t},e.children)},f="mdxType",p={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},u=n.forwardRef((function(e,t){var i=e.components,r=e.mdxType,a=e.originalType,l=e.parentName,d=s(e,["components","mdxType","originalType","parentName"]),f=c(i),u=r,b=f["".concat(l,".").concat(u)]||f[u]||p[u]||a;return i?n.createElement(b,o(o({ref:t},d),{},{components:i})):n.createElement(b,o({ref:t},d))}));function b(e,t){var i=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var a=i.length,o=new Array(a);o[0]=u;var s={};for(var l in t)hasOwnProperty.call(t,l)&&(s[l]=t[l]);s.originalType=e,s[f]="string"==typeof e?e:r,o[1]=s;for(var c=2;c<a;c++)o[c]=i[c];return n.createElement.apply(null,o)}return n.createElement.apply(null,i)}u.displayName="MDXCreateElement"},182:(e,t,i)=>{i.r(t),i.d(t,{assets:()=>l,contentTitle:()=>o,default:()=>p,frontMatter:()=>a,metadata:()=>s,toc:()=>c});var n=i(7462),r=(i(7294),i(3905));const a={title:"Little Endian Bitfields"},o=void 0,s={unversionedId:"guides/little-endian-bitfields",id:"guides/little-endian-bitfields",title:"Little Endian Bitfields",description:"Defining little endian bitfields is a little weird but is possible in COSMOS. However, note that APPEND does not work with little endian bitfields.",source:"@site/docs/guides/little-endian-bitfields.md",sourceDirName:"guides",slug:"/guides/little-endian-bitfields",permalink:"/docs/guides/little-endian-bitfields",draft:!1,editUrl:"https://github.com/OpenC3/cosmos/tree/main/docs.openc3.com/docs/guides/little-endian-bitfields.md",tags:[],version:"current",frontMatter:{title:"Little Endian Bitfields"},sidebar:"defaultSidebar",previous:{title:"Custom Widgets",permalink:"/docs/guides/custom-widgets"},next:{title:"Local Mode",permalink:"/docs/guides/local-mode"}},l={},c=[],d={toc:c},f="wrapper";function p(e){let{components:t,...i}=e;return(0,r.kt)(f,(0,n.Z)({},d,i,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("p",null,"Defining little endian bitfields is a little weird but is possible in COSMOS. However, note that APPEND does not work with little endian bitfields."),(0,r.kt)("p",null,"Here are the rules on how COSMOS handles LITTLE_ENDIAN data:"),(0,r.kt)("ol",null,(0,r.kt)("li",{parentName:"ol"},(0,r.kt)("p",{parentName:"li"},"COSMOS bit offsets are always defined in BIG_ENDIAN terms. Bit 0 is always the most significant bit of the first byte in a packet, and increasing from there.")),(0,r.kt)("li",{parentName:"ol"},(0,r.kt)("p",{parentName:"li"},"All 8, 16, 32, and 64-bit byte-aligned LITTLE_ENDIAN data types define their bit_offset as the most significant bit of the first byte in the packet that contains part of the item. (This is exactly the same as BIG_ENDIAN). Note that for all except 8-bit LITTLE_ENDIAN items, this is the LEAST significant byte of the item.")),(0,r.kt)("li",{parentName:"ol"},(0,r.kt)("p",{parentName:"li"},"LITTLE_ENDIAN bit fields are defined as any LITTLE_ENDIAN INT or UINT item that is not 8, 16, 32, or 64-bit and byte aligned.")),(0,r.kt)("li",{parentName:"ol"},(0,r.kt)("p",{parentName:"li"},"LITTLE_ENDIAN bit fields must define their bit_offset as the location of the most significant bit of the bitfield in BIG_ENDIAN space as described in rule 1 above. So for example. The following C struct at the beginning of a packet would be defined like so:"))),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-c"},'struct {\n  unsigned short a:4;\n  unsigned short b:8;\n  unsigned short c:4;\n}\n\nITEM A 4 4 UINT "struct item a"\nITEM B 12 8 UINT "struct item b"\nITEM C 8 4 UINT "struct item c"\n')),(0,r.kt)("p",null,"This is hard to visualize, but the structure above gets spread out in a byte array like the following after byte swapping: least significant 4 bits of b, 4-bits a, 4-bits c, most significant 4 bits of b."),(0,r.kt)("p",null,"The best advice is to experiment and use the View Raw feature in the Command and Telemetry Service to inspect the bytes of the packet and adjust as necessary."))}p.isMDXComponent=!0}}]);