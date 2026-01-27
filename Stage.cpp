#include "Stage.h"
#include <string>
#include <vector>
#include "Engine//Model.h"
#include "resource.h"

#include "imgui/imgui.h"
#include "imgui/imgui_impl_dx11.h"
#include "imgui/imgui_impl_win32.h"



Stage::Stage(GameObject* parent)
	:GameObject(parent, "Stage"), pMelbourne_(nullptr), pConstantBuffer_(nullptr)
{
	
}

Stage::~Stage()
{
}


void Stage::InitConstantBuffer()
{
	D3D11_BUFFER_DESC cb;
	cb.ByteWidth = sizeof(CONSTANTBUFFER_STAGE);
	cb.Usage = D3D11_USAGE_DYNAMIC;
	cb.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
	cb.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
	cb.MiscFlags = 0;
	cb.StructureByteStride = 0;

	// コンスタントバッファの作成
	HRESULT hr;
	hr = Direct3D::pDevice->CreateBuffer(&cb, nullptr, &pConstantBuffer_);
	if (FAILED(hr))
	{
		MessageBox(NULL, L"コンスタントバッファの作成に失敗しました", L"エラー", MB_OK);
	}
}

void Stage::Initialize()
{
	pMelbourne_ = new Sprite(L"Assets\\melbourne.png");
}

void Stage::Update()
{
	
}

void Stage::Draw()
{
	//コンスタントバッファを更新


	//コンスタントバッファ  1番から１スロット使う
	Direct3D::pContext->VSSetConstantBuffers(1, 1, &pConstantBuffer_);	//頂点シェーダー用	
	Direct3D::pContext->PSSetConstantBuffers(1, 1, &pConstantBuffer_);	//ピクセルシェーダー用


	static Transform t;
	t.scale_ = { 0.5f, 0.5f, 1.0f };
	t.rotate_.z += 0.01f;
	t.Calculation();
	//XMMATRIX worldMatrix = t.GetWorldMatrix();
	XMMATRIX worldMatrix = XMMatrixIdentity();
	pMelbourne_->Draw(worldMatrix);



	ImGui::Text("Stage Class rot:%lf", t.rotate_.z);
}

void Stage::Release()
{
}



