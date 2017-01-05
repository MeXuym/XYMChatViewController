#ifndef _DEFINE_H_
#define _DEFINE_H_

#include <string>
#include <vector>
#include <map>
#include <set>
using namespace std;

#define IM_LINK_REQUEST  1      //连接验证请求
#define IM_LINK_ANSWER  2      //

#define IM_WATCH_REQUEST  3      //心跳
#define IM_WATCH_ANSWER  4

#define IM_SERVICE_REQUEST  5      //服务请求
#define IM_SERVICE_ANSWER  6

const unsigned int MSG_TAG_HEADER = 0x01505348; //"HSP+0x01(协议版本号：1)"
typedef struct tagTcpPacketHeader
{
    unsigned int   uiDataLen;		//(前3个字节包头长度+数据长度)+1个字节指令
    unsigned int   htag;			// protocol header "HSP1"
    tagTcpPacketHeader()
    {
        htag = MSG_TAG_HEADER;
    }
}TcpPacketHeader,*LPTcpPacketHeader;
const unsigned int HEADER_PACKET_LEN  = sizeof(TcpPacketHeader);

#endif
