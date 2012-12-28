
// cmpeDlg.h : 头文件
//

#pragma once
#include "explorer.h"


// CcmpeDlg 对话框
class CcmpeDlg : public CDialogEx
{
// 构造
public:
	CcmpeDlg(CWnd* pParent = NULL);	// 标准构造函数

// 对话框数据
	enum { IDD = IDD_CMPE_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV 支持


// 实现
protected:
	HICON m_hIcon;

	// 生成的消息映射函数
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	DECLARE_EVENTSINK_MAP()
	void DocumentCompleteExplorer1(LPDISPATCH pDisp, VARIANT* URL);
	// 浏览器
	CExplorer1 m_IE;
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void setBrowserSize();
};
