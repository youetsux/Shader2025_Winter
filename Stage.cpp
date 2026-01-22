#include "Stage.h"
#include <string>
#include <vector>
#include "Engine//Model.h"
#include "resource.h"

#include "imgui/imgui.h"
#include "imgui/imgui_impl_dx11.h"
#include "imgui/imgui_impl_win32.h"



Stage::Stage(GameObject* parent)
	:GameObject(parent, "Stage"), pMelbourne_(nullptr)
{

}

Stage::~Stage()
{
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



